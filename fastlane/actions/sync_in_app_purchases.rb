module Fastlane
  module Actions
    class SyncInAppPurchasesAction < Action
      def self.run(params)
        require 'spaceship'
        require 'yaml'

        app_identifier = CredentialsManager::AppfileConfig.try_fetch_value(:app_identifier)
        app_id = Spaceship::ConnectAPI::App.find(app_identifier).id

        if File.exist?(params[:path])
          # Load existing purchases
          local_purchases = YAML.load(File.read(params[:path]))
          remote_purchases = download_in_app_purchases app_id

          local_and_remote_purchases = []
          local_purchases.each do |p|
            remote_purchase = nil
            remote_purchases.each do |rp|
              if p['id'] == rp['id'] || p['attributes']['productId'] == rp['attributes']['productId']
                remote_purchase = rp
              end
            end
            local_and_remote_purchases << { 'local' => p, 'remote' => remote_purchase }
          end

          new_local_purchases = []

          local_and_remote_purchases.each do |p|
            local_purchase = p['local']
            remote_purchase = p['remote']

            if remote_purchase.nil?
              # New purchase
              UI.message("Creating new in-app purchase #{local_purchase['attributes']['name']}")
              new_purchase = create_in_app_purchase(app_id, local_purchase)

              unless local_purchase['availability'].nil?
                new_purchase['availability'] =
                  create_in_app_purchase_availability(new_purchase['id'], local_purchase['availability'])
              end

              unless local_purchase['localizations'].nil?
                new_purchase['localizations'] = local_purchase['localizations'].map do |localization|
                  create_in_app_purchase_localization new_purchase['id'], localization
                end
              end

              unless local_purchase['pricePoint'].nil?
                new_purchase['pricePoint'] =
                  create_in_app_purchase_price_schedule new_purchase['id'], local_purchase['pricePoint']
              end

              new_local_purchases << new_purchase
            elsif local_purchase != remote_purchase
              # Updated purchase
              UI.message("Updating in-app purchase #{local_purchase['attributes']['name']}")
              updated_purchase = remote_purchase
              if local_purchase['attributes'] != remote_purchase['attributes']
                updated_purchase = update_in_app_purchase(remote_purchase['id'], local_purchase)
              end

              if local_purchase['availability'] != remote_purchase['availability']
                updated_purchase['availability'] =
                  create_in_app_purchase_availability(updated_purchase['id'], local_purchase['availability'])
              end

              unless local_purchase['localizations'].nil?
                updated_purchase['localizations'] = local_purchase['localizations'].map do |localization|
                  if localization['id'].nil?
                    create_in_app_purchase_localization updated_purchase['id'], localization
                  else
                    update_in_app_purchase_localization localization['id'], localization
                  end
                end
              end

              if local_purchase['pricePoint'] != remote_purchase['pricePoint']
                updated_purchase['pricePoint'] =
                  create_in_app_purchase_price_schedule updated_purchase['id'], local_purchase['pricePoint']
              end

              new_local_purchases << updated_purchase
            else
              # Unchanged purchase
              new_local_purchases << remote_purchase || local_purchase
            end
          end

          new_local_purchases.sort_by! { |p| p['attributes']['name'] }

          # Write purchases to file
          File.write(params[:path], new_local_purchases.to_yaml)
        else
          purchases = download_in_app_purchases app_id
          # Write purchases to file
          File.write(params[:path], purchases.to_yaml)

          UI.success("Successfully synced #{purchases.count} in-app purchases to #{params[:path]}")
        end
      end

      def self.create_in_app_purchase(app_id, purchase)
        resp = other_action.connect_api(
          http_method: 'POST',
          path: '/v2/inAppPurchases',
          params: {
            data: {
              type: 'inAppPurchases',
              attributes: {
                familySharable: purchase['attributes']['familySharable'],
                inAppPurchaseType: purchase['attributes']['inAppPurchaseType'],
                name: purchase['attributes']['name'],
                productId: purchase['attributes']['productId'],
                reviewNote: purchase['attributes']['reviewNote'] || ''
              },
              relationships: {
                app: {
                  data: {
                    id: app_id,
                    type: 'apps'
                  }
                }
              }
            }
          }
        )

        {
          'id' => resp['data']['id'],
          'attributes' => {
            'familySharable' => resp['data']['attributes']['familySharable'],
            'inAppPurchaseType' => resp['data']['attributes']['inAppPurchaseType'],
            'name' => resp['data']['attributes']['name'],
            'productId' => resp['data']['attributes']['productId'],
            'reviewNote' => resp['data']['attributes']['reviewNote'] || ''
          }
        }
      end

      def self.update_in_app_purchase(purchase_id, purchase)
        resp = other_action.connect_api(
          http_method: 'PATCH',
          path: "/v2/inAppPurchases/#{purchase_id}",
          params: {
            data: {
              id: purchase_id,
              type: 'inAppPurchases',
              attributes: {
                familySharable: purchase['attributes']['familySharable'],
                name: purchase['attributes']['name'],
                reviewNote: purchase['attributes']['reviewNote'] || ''
              }
            }
          }
        )

        {
          'id' => resp['data']['id'],
          'attributes' => {
            'familySharable' => resp['data']['attributes']['familySharable'],
            'inAppPurchaseType' => resp['data']['attributes']['inAppPurchaseType'],
            'name' => resp['data']['attributes']['name'],
            'productId' => resp['data']['attributes']['productId'],
            'reviewNote' => resp['data']['attributes']['reviewNote'] || ''
          }
        }
      end

      def self.create_in_app_purchase_localization(purchase_id, localization)
        resp = other_action.connect_api(
          http_method: 'POST',
          path: '/v1/inAppPurchaseLocalizations',
          params: {
            data: {
              type: 'inAppPurchaseLocalizations',
              attributes: {
                name: localization['name'],
                description: localization['description'],
                locale: localization['locale']
              },
              relationships: {
                inAppPurchaseV2: {
                  data: {
                    id: purchase_id,
                    type: 'inAppPurchases'
                  }
                }
              }
            }
          }
        )

        {
          'id' => resp['data']['id'],
          'description' => resp['data']['attributes']['description'],
          'name' => resp['data']['attributes']['name'],
          'locale' => resp['data']['attributes']['locale']
        }
      end

      def self.update_in_app_purchase_localization(localization_id, localization)
        resp = other_action.connect_api(
          http_method: 'PATCH',
          path: "/v1/inAppPurchaseLocalizations/#{localization_id}",
          params: {
            data: {
              id: localization_id,
              type: 'inAppPurchaseLocalizations',
              attributes: {
                name: localization['name'],
                description: localization['description']
              }
            }
          }
        )

        {
          'id' => resp['data']['id'],
          'description' => resp['data']['attributes']['description'],
          'name' => resp['data']['attributes']['name'],
          'locale' => resp['data']['attributes']['locale']
        }
      end

      def self.create_in_app_purchase_price_schedule(purchase_id, price_schedule)
        price_points_resp = other_action.connect_api(
          http_method: 'GET',
          path: "/v2/inAppPurchases/#{purchase_id}/pricePoints",
          params: {
            'filter[territory]': 'USA',
            'include': 'territory',
            'limit': 200
          }
        )
        target_price_point = price_points_resp['data'].find do |pp|
          pp['attributes']['customerPrice'] == price_schedule['customerPrice']
        end
        UI.user_error!("Could not find price point for #{price_schedule['customerPrice']}") if target_price_point.nil?

        resp = other_action.connect_api(
          http_method: 'POST',
          path: '/v1/inAppPurchasePriceSchedules',
          params: {
            data: {
              type: 'inAppPurchasePriceSchedules',
              relationships: {
                inAppPurchase: {
                  data: {
                    id: purchase_id,
                    type: 'inAppPurchases'
                  }
                },
                manualPrices: {
                  data: [{
                    type: 'inAppPurchasePrices',
                    id: '${price1}'
                  }]
                }
              }
            },
            included: [
              {
                type: 'inAppPurchasePrices',
                id: '${price1}',
                attributes: {
                  startDate: nil
                },
                relationships: {
                  inAppPurchaseV2: {
                    data: {
                      id: purchase_id,
                      type: 'inAppPurchases'
                    }
                  },
                  inAppPurchasePricePoint: {
                    data: {
                      id: target_price_point['id'],
                      type: 'inAppPurchasePricePoints'
                    }
                  }
                }
              }
            ]
          }
        )

        {
          'id' => target_price_point['id'],
          'customerPrice' => price_schedule['customerPrice']
        }
      end

      def self.create_in_app_purchase_availability(purchase_id, availability)
        territories_resp = other_action.connect_api(
          http_method: 'GET',
          path: '/v1/territories',
          params: {
            limit: 200
          }
        )
        resp = other_action.connect_api(
          http_method: 'POST',
          path: '/v1/inAppPurchaseAvailabilities',
          params: {
            data: {
              type: 'inAppPurchaseAvailabilities',
              attributes: {
                availableInNewTerritories: availability['attributes']['availableInNewTerritories']
              },
              relationships: {
                availableTerritories: {
                  data: territories_resp['data'].map do |t|
                    {
                      id: t['id'],
                      type: 'territories'
                    }
                  end
                },
                inAppPurchase: {
                  data: {
                    id: purchase_id,
                    type: 'inAppPurchases'
                  }
                }
              }
            }
          }
        )

        {
          'id' => resp['data']['id'],
          'attributes' => resp['data']['attributes']
        }
      end

      def self.download_in_app_purchases(app_id)
        UI.message("Downloading in-app purchases for app #{app_id}")
        # Download purchases from API
        resp = other_action.connect_api(
          http_method: 'GET',
          path: "/v1/apps/#{app_id}/inAppPurchasesV2",
          params: {
            limit: 200
          }
        )
        purchases = resp['data']

        # Create hash of purchases
        file_data = []
        purchases.each do |purchase|
          localizations_resp = other_action.connect_api(
            http_method: 'GET',
            path: "/v2/inAppPurchases/#{purchase['id']}/inAppPurchaseLocalizations",
            params: {
              limit: 200
            }
          )
          # price_points_resp = other_action.connect_api(
          #   http_method: 'GET',
          #   path: "/v2/inAppPurchases/#{purchase['id']}/pricePoints",
          #   params: {
          #     limit: 200
          #   }
          # )
          price_points_resp = {
            'included' => []
          }
          begin
            price_points_resp = other_action.connect_api(
              http_method: 'GET',
              path: "/v1/inAppPurchasePriceSchedules/#{purchase['id']}/manualPrices",
              params: {
                'fields[inAppPurchasePrices]': 'inAppPurchasePricePoint',
                'include': 'inAppPurchasePricePoint'
              }
            )
          rescue StandardError => e
            UI.message("Error getting price point for #{purchase['id']}: #{e}")
          end
          availability_resp = {
            'data' => {}
          }
          begin
            availability_resp = other_action.connect_api(
              http_method: 'GET',
              path: "/v2/inAppPurchases/#{purchase['id']}/inAppPurchaseAvailability",
              params: {}
            )
          rescue StandardError => e
            UI.message("Error getting availability for #{purchase['id']}: #{e}")
          end
          file_data << {
            'id' => purchase['id'],
            'attributes' => {
              'familySharable' => purchase['attributes']['familySharable'],
              'inAppPurchaseType' => purchase['attributes']['inAppPurchaseType'],
              'name' => purchase['attributes']['name'],
              'productId' => purchase['attributes']['productId'],
              'reviewNote' => purchase['attributes']['reviewNote'] || ''
            },
            'localizations' => localizations_resp['data'].map do |l|
                                 {
                                   'id' => l['id'],
                                   'name' => l['attributes']['name'],
                                   'description' => l['attributes']['description'],
                                   'locale' => l['attributes']['locale']
                                 }
                               end,
            'pricePoint' => {
              'id' => price_points_resp['included']&.first&.dig('id'),
              'customerPrice' => price_points_resp['included']&.first&.dig('attributes', 'customerPrice')
            },
            'availability' => {
              'id' => availability_resp['data']['id'],
              'attributes' => availability_resp['data']['attributes']
            }
          }
        end

        file_data
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        'Syncs in-app purchases to a JSON file in the metadata folder using the App Store Connect API'
      end

      def self.authors
        ['evandcoleman']
      end

      def self.is_supported?(_platform)
        true
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :path,
                                       env_name: 'IN_APP_PURCHASES_METADATA_PATH',
                                       description: 'Path to the YAML file to store IAP metadata',
                                       default_value: './fastlane/metadata/in_app_purchases.yaml',
                                       optional: true)
        ]
      end
    end
  end
end
