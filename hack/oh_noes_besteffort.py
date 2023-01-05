#!/usr/bin/python3
import sys
import yaml

BANNED_STATUSES = {"besteffort"}


def is_app(data: dict) -> bool:
    try:
        return "app-1" in data["$schema"]
    except KeyError:
        return False


def assert_valid_app(filename: str) -> None:
    with open(sys.argv[1], encoding='utf8') as f:
        d = yaml.safe_load(f)
        if is_app(d):
            st = d["onboardingStatus"]
            if st.lower() in BANNED_STATUSES:
                raise ValueError(
                    f"{st} apps are no longer accepted. Please read "
                    "https://gitlab.cee.redhat.com/app-sre/contract/-/blob/master/README.md#notes "  # noqa: E501
                    "for more details"
                )
            else:
                print("App in valid status: ", st)
        else:
            print(f"{filename} not an app. Skipping")


if __name__ == "__main__":
    assert_valid_app(sys.argv[1])
