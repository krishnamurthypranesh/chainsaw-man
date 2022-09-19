from typing import List


class JournalEntryHelper:
    def __init__(self):
        pass

    def validate_journal_content(content: dict) -> bool:
        """
        checks the content of the journal received to see if the content
        provided by the user is valid.

        Returns:
            Success:
                True
            Failure:
                False
        """

        isContentValid: bool = True

        KEYS = {
            "amor_fati": [
                "thoughts",
            ],
            "premeditatio_malorum": ["vice", "strategy"],
        }

        for k in KEYS:
            if content.get(k) is None:
                isContentValid = False
                break
            else:
                for ik in KEYS[k]:
                    if content[k]["fields"].get(ik) is None:
                        isContentValid = False
                        break
                    else:
                        value: str = content[k]["fields"][ik]["value"]
                        if len(value) == 0:
                            isContentValid = False
                            break

        return isContentValid


def get_helper():
    yield JournalEntryHelper()
