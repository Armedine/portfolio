from ngcp_dataeng_iterable_tooling.genericapi import GenericApi


class IterableConnector:
    def __init__(self, project: str):
        # config:
        self.project = project
        # globals:
        self.api = GenericApi()
        self.creds = {
            "prod": "",
            "dev": "",
            "marketing": "",
            "marketplaces": "",
            "internal": "",
        }
        self.endpoints = {"endpoint": "https://api.iterable.com"}
        self.build_header()

    def build_header(self):
        self.api.set_header(api_key=self.creds[self.project])

    def _call(self, endpoint=None, http_type=None, payload=None):
        return self.api.call(
            url=self._build_endpoint(endpoint),
            http_type=http_type,
            payload=payload,
        )

    def _build_endpoint(self, endpoint: str):
        return self.api.add_parameters(self.endpoints["endpoint"] + endpoint)

    def _parameterize(self, url: str, data_args=None):
        # pass in a url path and parameter values to append to it.
        new_url = url.replace("?", "$").replace("&", "$")
        if data_args:
            for key, val in data_args.items():
                new_url = new_url + "$" + key + "=" + val
        return new_url.replace("$", "?", 1).replace("$", "&")

    def get_message_html(self, content: bytes):
        # @returns string
        # convert bytes content from response content to html text (utf-8)
        # example use: get_message_html(my_response.content)
        return content.decode("utf-8")

    def get_user_by_email(self, email: str):
        return self._call(f"/api/users/{email}", "get")

    def get_events_by_email(self, email: str):
        # returns max of 200 events
        return self._call(f"/api/events/{email}", "get")

    def get_export_events_by_email(self, email: str):
        # bulk exports all user events
        return self._call(
            f"/api/export/userEvents?email={email}&includeCustomEvents=true",
            "get",
        )

    def get_export_events(self, **kwargs):
        endpoint = f"/api/export/data.csv"
        return self._call(self.api.add_parameters(endpoint, **kwargs), "get")

    def get_events_by_user(self, user_id: str, limit=None):
        # returns max of 200 events; default 30
        return self._call(
            f"/api/events/byUserId/{user_id}&limit={limit}", "get"
        )

    def get_messages_sent_to_user(self, **kwargs):
        # kwargs supports: @email (str, *required), @limit (int), @userId (str), @campaignIds (array),
        # @startDateTime (str), @endDateTime (str), @messageMedium (str)
        # *note: this automatically defaults to a limit of 10, max 1000 with @limit
        # example use: get_messages_sent_to_user(email='test@test.com', limit=50)
        endpoint = f'/api/users/getSentMessages?email={kwargs["email"]}'
        return self._call(self.api.add_parameters(endpoint, **kwargs), "get")

    def get_previous_message(self, email: str, message_id: str):
        # gets the html of a message id previously sent to a user.
        return self._call(
            f"/api/email/viewInBrowser?email={email}&messageId={message_id}",
            "get",
        )

    def get_email_template(self, template_id: int):
        return self._call(
            f"/api/templates/email/get?templateId={str(template_id)}", "get"
        )

    def get_push_template(self, template_id: int):
        return self._call(
            f"/api/templates/push/get?templateId={str(template_id)}", "get"
        )

    def get_list(self, list_id: int):
        return self._call(f"/api/lists/getUsers?listId={str(list_id)}", "get")

    def get_all_email_templates(
        self, template_type: str, medium: str, start: str, end: str
    ):
        # @kwargs: [optional] template_type: str, msg_medium: str, start_time: date, end_time: date
        params = {
            "templateType": template_type,
            "messageMedium": medium,
            "startDateTime": start,
            "endDateTime": end,
        }
        return self._call(self._parameterize("/api/templates", params), "get")

    def get_campaign_metadata(self):
        # gets a list of campaigns and their states
        return self._call(f"/api/campaigns", "get")

    def post_custom_event(
        self,
        email: str,
        event_name: str,
        campaign: str,
        data_fields: object,
        **kwargs,
    ):
        js = {
            "email": email,
            "eventName": event_name,
            "campaign": campaign or None,
            "dataFields": data_fields,
        }
        if kwargs.get("ignore_metadata", False):
            js["provider_metadata"] = dict(campaign=campaign or None)
        return self._call(
            endpoint=f"/api/events/track", http_type="post", payload=js
        )
