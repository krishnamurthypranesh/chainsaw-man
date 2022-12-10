from typing import List

from app.models.journal_entry import JournalEntryContent


class JournalEntryHelper:
    def __init__(self):
        """Empty because this does not need intialization
        """
        pass

    
    @staticmethod
    def validate_journal_content(content: JournalEntryContent) -> bool:
        """
        checks the content of the journal received to see if the content
        provided by the user is valid.

        Returns:
            Success:
                True
            Failure:
                False
        """

        is_content_valid: bool = True
        # TODO: implement validation logic
        return is_content_valid


def get_journal_entry_helper():
    yield JournalEntryHelper()
