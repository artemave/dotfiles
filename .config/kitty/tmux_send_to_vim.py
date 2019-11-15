# -*- coding: UTF-8 -*-

import re
import os
from kittens.tui.loop import debug

def camel_to_snake(string):
    s1 = re.sub('(.)([A-Z][a-z]+)', r'\1_\2', string)
    return re.sub('([a-z0-9])([A-Z])', r'\1_\2', s1).lower()

def mark(text, args, Mark, extra_cli_args, *a):
    # This function is responsible for finding all
    # matching text.
    # We mark all individual word for potential selection

    regexp = re.compile(
            '(?P<rails_log_controller>(?:[A-Z]\\w*::)*[A-Z]\\w*Controller#\\w+)|'
            'Rendered (?P<rails_log_partial>[-a-zA-Z0-9_+-,./]+)|'
            '(?P<url>(https?|tcp)://[-a-zA-Z0-9@:%._\+~#=]{2,256}\\b([-a-zA-Z0-9@:%_\\+.~#?&/=]*))|'
            '(?P<path>([~./]?[-a-zA-Z0-9_+-,./]+(?::\\d+)?))'
            )

    mark_idx = 0
    for idx, m in enumerate(re.finditer(regexp, text)):
        start, end = m.span()
        mark_text = text[start:end].replace('\n', '').replace('\0', '')

        path_match = m.groupdict()['path']
        url_match = m.groupdict()['url']
        rails_controller_match = m.groupdict()['rails_log_controller']
        rails_partial_match = m.groupdict()['rails_log_partial']

        mark_data = {}

        if path_match:
            parts = mark_text.rsplit(':', 1)
            file_path = parts[0]
            line_number = None

            if len(parts) > 1:
                line_number = parts[1]

            if file_path != '.' and file_path != '..' and file_path != '/' and os.path.exists(file_path):
                mark_data = {
                        'file_path': file_path,
                        'line_number': line_number
                        }

        elif rails_partial_match:
            start, end = m.span('rails_log_partial')
            mark_text = text[start:end].replace('\n', '').replace('\0', '')
            mark_data = {
                    'file_path': './app/views/' + mark_text
                    }

        elif url_match:
                mark_data = {
                        'url': mark_text
                        }

        elif rails_controller_match:
            controller_class, action = mark_text.split('#')
            controller_path = './app/controllers/' + '/'.join(
                    map(camel_to_snake, controller_class.split('::'))
                    ) + '.rb'
            method_def_regex = re.compile('^\\s*def\\s+%s' % (action))

            if os.path.exists(controller_path):
                with open(controller_path) as ruby_file:
                    line_number = 0
                    for line in ruby_file:
                        line_number += 1

                        if method_def_regex.match(line):
                            mark_data = {
                                    'file_path': controller_path,
                                    'line_number': line_number
                                    }

        # mark_data will be available in data['groupdicts']
        if mark_data:
            yield Mark(mark_idx, start, end, mark_text, mark_data)
            mark_idx += 1

def handle_result(args, data, target_window_id, boss, extra_cli_args, *a):
    # This function is responsible for performing some
    # action on the selected text.
    # matches is a list of the selected entries and groupdicts contains
    # the arbitrary data associated with each entry in mark() above
    tmux_window_name = 'vim' if len(extra_cli_args) == 0 else extra_cli_args[0]

    matches, groupdicts = [], []
    for m, g in zip(data['match'], data['groupdicts']):
        if m:
            matches.append(m), groupdicts.append(g)

    for word, data in zip(matches, groupdicts):
        # Lookup the word in a dictionary, the open_url function
        # will open the provided url in the system browser
        if 'url' in data:
            boss.open_url(data['url'])

        if 'file_path' in data:
            os.system('tmux select-window -t %s' % (tmux_window_name))
            os.system('tmux send-keys Escape')

            if 'line_number' in data:
                os.system('tmux send-keys ":e +%s %s"' %(data['line_number'], data['file_path']))
            else:
                os.system('tmux send-keys ":e %s"' %(data['file_path']))

            os.system('tmux send-keys Enter')
            os.system('tmux send-keys zz')

# if __name__ == "__main__":
#     cwd = os.getcwd()
#     debug({'cwd': cwd})

if __name__ == "change to __main__ when running this directly":
    from pprint import pprint

    text = """
Completed 200 OK in 213ms (Views: 173.1ms | ActiveRecord: 18.7ms | Allocations: 40616)


Started GET "/en/checkout/shipping_addresses/new" for ::1 at 2019-11-12 16:39:35 +0100
Processing by CheckoutShippingAddressesController#new as HTML
  Parameters: {"locale"=>"en"}
  Client Load (0.4ms)  SELECT "clients".* FROM "clients" WHERE "clients"."subdomain" = $1 LIMIT $2  [["subdomain", "zams"], ["LIMIT", 1]]
  ↳ app/controllers/concerns/tenantable.rb:22:in `current_tenant_is_client_with'
  User Load (0.5ms)  SELECT "users".* FROM "users" WHERE "users"."client_id" = $1 AND "users"."id" = $2 LIMIT $3  [["client_id", 898370464], ["id", 80395490], ["LIMIT", 1]]
  ↳ app/controllers/client_base_controller.rb:52:in `current_user'
  Page Load (1.4ms)  SELECT slug, title FROM "pages" WHERE "pages"."client_id" = $1  [["client_id", 898370464]]
  ↳ app/models/page.rb:19:in `all_slugs_and_titles'
  Basket Load (0.6ms)  SELECT "baskets".* FROM "baskets" WHERE "baskets"."client_id" = $1 AND "baskets"."user_id" = $2 LIMIT $3  [["client_id", 898370464], ["user_id", 80395490], ["LIMIT", 1]]
  ↳ app/controllers/concerns/basketable.rb:14:in `current_basket'
  ClientConfig Load (0.5ms)  SELECT "client_configs".* FROM "client_configs" WHERE "client_configs"."client_id" = $1 ORDER BY "client_configs"."id" DESC LIMIT $2  [["client_id", 898370464], ["LIMIT", 1]]
  ↳ app/models/client_config.rb:53:in `entity'
  Rendering checkout_shipping_addresses/new.html.erb within layouts/application
  Rendered partials/_form_errors.html.erb (Duration: 0.1ms | Allocations: 16)
  Rendered partials/_shipping_address_fields.html.erb (Duration: 21.7ms | Allocations: 2760)
  ShippingAddress Exists? (0.6ms)  SELECT 1 AS one FROM "addresses" WHERE "addresses"."client_id" = $1 AND "addresses"."type" = $2 AND "addresses"."user_id" = $3 LIMIT $4  [["client_id", 898370464], ["type", "ShippingAddress"], ["user_id", 80395490], ["LIMIT", 1]]
  ↳ app/views/checkout_shipping_addresses/new.html.erb:20
  BasketItemGroup Load (0.5ms)  SELECT "basket_item_groups".* FROM "basket_item_groups" WHERE "basket_item_groups"."client_id" = $1 AND "basket_item_groups"."basket_id" = $2  [["client_id", 898370464], ["basket_id", 342761]]
  ↳ app/models/basket.rb:48:in `all?'
  VetPrescription Load (1.1ms)  SELECT "vet_prescriptions".* FROM "vet_prescriptions" WHERE "vet_prescriptions"."client_id" = $1 AND "vet_prescriptions"."id" = $2 LIMIT $3  [["client_id", 898370464], ["id", 1029531330], ["LIMIT", 1]]
  ↳ app/models/basket.rb:48:in `block in all_items_ungrouped?'
  ContactLensPrescription Load (0.5ms)  SELECT "contact_lens_prescriptions".* FROM "contact_lens_prescriptions" WHERE "contact_lens_prescriptions"."client_id" = $1 AND "contact_lens_prescriptions"."id" = $2 LIMIT $3  [["client_id", 898370464], ["id", 447876413], ["LIMIT", 1]]
  ↳ app/models/basket.rb:107:in `map'
  VetPrescriptionDetail Load (0.5ms)  SELECT "vet_prescription_details".* FROM "vet_prescription_details" WHERE "vet_prescription_details"."client_id" = $1 AND "vet_prescription_details"."vet_prescription_id" = $2 LIMIT $3  [["client_id", 898370464], ["vet_prescription_id", 1029531330], ["LIMIT", 1]]
  ↳ app/models/vet_prescription.rb:66:in `checkoutable?'
  ContactLensPrescriptionDetail Load (0.6ms)  SELECT "contact_lens_prescription_details".* FROM "contact_lens_prescription_details" WHERE "contact_lens_prescription_details"."client_id" = $1 AND "contact_lens_prescription_details"."contact_lens_prescription_id" = $2 LIMIT $3  [["client_id", 898370464], ["contact_lens_prescription_id", 447876413], ["LIMIT", 1]]
  ↳ app/models/contact_lens_prescription.rb:45:in `checkoutable?'
  Rendered partials/_checkout_accordion_basket_items.html.erb (Duration: 37.9ms | Allocations: 11096)
  Card Load (1.3ms)  SELECT "cards".* FROM "cards" WHERE "cards"."client_id" = $1 AND "cards"."id" = $2 LIMIT $3  [["client_id", 898370464], ["id", 141474312], ["LIMIT", 1]]
  ↳ app/views/partials/_checkout_accordion_payment.html.erb:1
  Rendered partials/_checkout_accordion_payment.html.erb (Duration: 19.3ms | Allocations: 3743)
  Rendered partials/_checkout_accordion_place_order.html.erb (Duration: 1.8ms | Allocations: 400)
Completed 200 OK in 213ms (Views: 173.1ms | ActiveRecord: 18.7ms | Allocations: 40616)


Started GET "/en/checkout/shipping_addresses/new" for ::1 at 2019-11-12 16:39:35 +0100
Processing by CheckoutShippingAddressesController#new as HTML
  Parameters: {"locale"=>"en"}
  Client Load (0.4ms)  SELECT "clients".* FROM "clients" WHERE "clients"."subdomain" = $1 LIMIT $2  [["subdomain", "zams"], ["LIMIT", 1]]
  ↳ app/controllers/concerns/tenantable.rb:22:in `current_tenant_is_client_with'
  User Load (0.5ms)  SELECT "users".* FROM "users" WHERE "users"."client_id" = $1 AND "users"."id" = $2 LIMIT $3  [["client_id", 898370464], ["id", 80395490], ["LIMIT", 1]]
  ↳ app/controllers/client_base_controller.rb:52:in `current_user'
  Page Load (1.4ms)  SELECT slug, title FROM "pages" WHERE "pages"."client_id" = $1  [["client_id", 898370464]]
  ↳ app/models/page.rb:19:in `all_slugs_and_titles'
  Basket Load (0.6ms)  SELECT "baskets".* FROM "baskets" WHERE "baskets"."client_id" = $1 AND "baskets"."user_id" = $2 LIMIT $3  [["client_id", 898370464], ["user_id", 80395490], ["LIMIT", 1]]
  ↳ app/controllers/concerns/basketable.rb:14:in `current_basket'
  ClientConfig Load (0.5ms)  SELECT "client_configs".* FROM "client_configs" WHERE "client_configs"."client_id" = $1 ORDER BY "client_configs"."id" DESC LIMIT $2  [["client_id", 898370464], ["LIMIT", 1]]
  ↳ app/models/client_config.rb:53:in `entity'
  Rendering checkout_shipping_addresses/new.html.erb within layouts/application
  Rendered partials/_form_errors.html.erb (Duration: 0.1ms | Allocations: 16)
  Rendered partials/_shipping_address_fields.html.erb (Duration: 21.7ms | Allocations: 2760)
  ShippingAddress Exists? (0.6ms)  SELECT 1 AS one FROM "addresses" WHERE "addresses"."client_id" = $1 AND "addresses"."type" = $2 AND "addresses"."user_id" = $3 LIMIT $4  [["client_id", 898370464], ["type", "ShippingAddress"], ["user_id", 80395490], ["LIMIT", 1]]
  ↳ app/views/checkout_shipping_addresses/new.html.erb:20
  BasketItemGroup Load (0.5ms)  SELECT "basket_item_groups".* FROM "basket_item_groups" WHERE "basket_item_groups"."client_id" = $1 AND "basket_item_groups"."basket_id" = $2  [["client_id", 898370464], ["basket_id", 342761]]
  ↳ app/models/basket.rb:48:in `all?'
  VetPrescription Load (1.1ms)  SELECT "vet_prescriptions".* FROM "vet_prescriptions" WHERE "vet_prescriptions"."client_id" = $1 AND "vet_prescriptions"."id" = $2 LIMIT $3  [["client_id", 898370464], ["id", 1029531330], ["LIMIT", 1]]
  ↳ app/models/basket.rb:48:in `block in all_items_ungrouped?'
  ContactLensPrescription Load (0.5ms)  SELECT "contact_lens_prescriptions".* FROM "contact_lens_prescriptions" WHERE "contact_lens_prescriptions"."client_id" = $1 AND "contact_lens_prescriptions"."id" = $2 LIMIT $3  [["client_id", 898370464], ["id", 447876413], ["LIMIT", 1]]
  ↳ app/models/basket.rb:107:in `map'
  VetPrescriptionDetail Load (0.5ms)  SELECT "vet_prescription_details".* FROM "vet_prescription_details" WHERE "vet_prescription_details"."client_id" = $1 AND "vet_prescription_details"."vet_prescription_id" = $2 LIMIT $3  [["client_id", 898370464], ["vet_prescription_id", 1029531330], ["LIMIT", 1]]
  ↳ app/models/vet_prescription.rb:66:in `checkoutable?'
  ContactLensPrescriptionDetail Load (0.6ms)  SELECT "contact_lens_prescription_details".* FROM "contact_lens_prescription_details" WHERE "contact_lens_prescription_details"."client_id" = $1 AND "contact_lens_prescription_details"."contact_lens_prescription_id" = $2 LIMIT $3  [["client_id", 898370464], ["contact_lens_prescription_id", 447876413], ["LIMIT", 1]]
  ↳ app/models/contact_lens_prescription.rb:45:in `checkoutable?'
  Rendered partials/_checkout_accordion_basket_items.html.erb (Duration: 37.9ms | Allocations: 11096)
  Card Load (1.3ms)  SELECT "cards".* FROM "cards" WHERE "cards"."client_id" = $1 AND "cards"."id" = $2 LIMIT $3  [["client_id", 898370464], ["id", 141474312], ["LIMIT", 1]]
  ↳ app/views/partials/_checkout_accordion_payment.html.erb:1
  Rendered partials/_checkout_accordion_payment.html.erb (Duration: 19.3ms | Allocations: 3743)
  Rendered partials/_checkout_accordion_place_order.html.erb (Duration: 1.8ms | Allocations: 400)
  http://localhost:3000 tcp://localhost:5000 https://www.google.com/s?q=stuff
    """

    def ap(idx, start, end, mark_text, groupdicts):
        pprint.pprint({
            'idx': idx,
            'start': start,
            'end': end,
            'mark_text': mark_text,
            'groupdicts': groupdicts
            })

    marks = mark(text, None, ap, [])
    for mark in marks:
        print('new mark')
