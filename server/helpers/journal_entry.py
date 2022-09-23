from typing import List

from models.journal_entry import JournalEntryContent


class JournalEntryHelper:
    def __init__(self):
        pass

    def validate_journal_content(self, content: JournalEntryContent) -> bool:
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
        # TODO: implement validation logic
        return isContentValid


def get_helper():
    yield JournalEntryHelper()
