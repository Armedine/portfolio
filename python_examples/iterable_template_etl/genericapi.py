import requests
import time
import json


class GenericApi:
    # Basic wrapper for http types 'post', 'get', and 'delete' with simple error handling and up to 3 retries.
    def __init__(self):
        # config:
        self.max_tries = 3
        self.timeout = 10.0
        self.dev_mode = False
        self.cadence = 0.03
        # globals:
        self.header = {}
        self.attempt = 0
        self.call_count = 0

    def call(self, url: str, http_type: str, **kwargs):
        time.sleep(self.cadence)  # throttle.
        js = kwargs.get("payload", None)
        self.call_count = self.call_count + 1
        # run call:
        while self.attempt < self.max_tries:
            self.attempt = self.attempt + 1
            # determine call type:
            if http_type == "post":
                r = requests.post(
                    url=url,
                    headers=self.header or {},
                    timeout=self.timeout,
                    json=js,
                )
            elif http_type == "get":
                r = requests.get(
                    url=url, headers=self.header or {}, timeout=self.timeout
                )
            elif http_type == "delete":
                r = requests.delete(
                    url=url, headers=self.header or {}, timeout=self.timeout
                )
            else:
                r = None
                print(
                    '_run_call: invalid http_type provided (currently only supports "post" and "get")'
                )
            if self.dev_mode and r:
                print("api: call number", self.call_count)
                print(r.status_code, r.reason, "\n")
            elif self.dev_mode and r is None:
                raise TypeError(
                    "Dev mode error: response failed to generate ('r' was None)."
                )
            # handle response:
            if 300 > r.status_code >= 200:
                if self.attempt > 1:
                    print(
                        "retry resolved: call",
                        self.call_count,
                        "attempt",
                        self.attempt,
                    )
                break  # call made, end try loop.
            elif (
                r.status_code == 408
                or r.status_code == 409
                or r.status_code == 425
                or r.status_code == 429
            ):
                if r.status_code == 429:
                    print(
                        "caution: rate limit hit on call",
                        self.call_count,
                        "attempt",
                        self.attempt,
                    )
                else:
                    print(
                        "caution: timed out on call",
                        self.call_count,
                        "attempt",
                        self.attempt,
                    )
                if self.attempt < self.max_tries:
                    self.attempt = (
                        self.attempt + 1
                    )  # allow try loop to continue if max_tries not reached.
                else:
                    print(
                        "warning: reached max retries for call",
                        self.call_count,
                    )
            elif r.status_code == 404:
                print(f"404: endpoint does not exist: {url}")
                self.attempt = self.max_tries
            elif r.status_code == 400:
                print(f"400: endpoint malformed: {url}")
                self.attempt = self.max_tries
            else:
                print(
                    "unhandled response error: call",
                    str(self.call_count) + ":",
                    "'" + str(r.status_code) + "'",
                    "with reason",
                    "'" + r.reason + "'",
                )
        self.attempt = 0
        return r

    def add_parameters(self, url, **kwargs):
        # pass in a url path and parameter values to append to it.
        new_url = url.replace("?", "$").replace("&", "$")
        if kwargs:
            for key, val in kwargs.items():
                new_url = new_url + "$" + str(key) + "=" + str(val)
        return new_url.replace("$", "?", 1).replace("$", "&")

    def set_header(self, **kwargs):
        for key, val in kwargs.items():
            self.header[key] = val

    def print_response(self, r):
        print(json.dumps(r.json(), indent=4))
