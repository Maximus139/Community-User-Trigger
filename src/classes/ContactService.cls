public without sharing class ContactService {
    public static final String DEFAULT_COMMUNITY_PROFILE_NAME = Label.Default_Community_User_Profile_Name;
    public static final String SUCCESS_STRING = 'Success';

    public void handleCreateCommunityUser(Map<Id, Contact> oldContactsMap, List<Contact> newContacts) {
        List<Contact> changedContacts = new List<Contact>();

        for (Contact newContact : newContacts) {
            Contact oldContact = oldContactsMap.get(newContact.Id);

            if (oldContact.Is_Customer__c != newContact.Is_Customer__c) {
                changedContacts.add(newContact);
            }
        }

        if (!changedContacts.isEmpty()) {
            handleCreateCommunityUser(changedContacts);
        }
    }

    public void handleCreateCommunityUser(List<Contact> contacts) {
        Map<User, Boolean> usersToUpdateByActiveStatus = new Map<User, Boolean>();
        List<Contact> contactsWithoutCommunityUser = new List<Contact>();
        Map<Id, User> communityUsersByPersonContactIds = new Map<Id, User>();

        for (User communityUser : [SELECT Id, ContactId FROM User WHERE ContactId IN :contacts]) {
            communityUsersByPersonContactIds.put(communityUser.ContactId, communityUser);
        }

        for (Contact contact : contacts) {
            if (contact.Is_Customer__c) {
                if (!communityUsersByPersonContactIds.containsKey(contact.Id)) {
                    contactsWithoutCommunityUser.add(contact);
                } else {
                    usersToUpdateByActiveStatus.put(communityUsersByPersonContactIds.get(contact.Id), true);
                }
            } else {
                if (communityUsersByPersonContactIds.containsKey(contact.Id)) {
                    usersToUpdateByActiveStatus.put(communityUsersByPersonContactIds.get(contact.Id), false);
                }
            }
        }

        if (!contactsWithoutCommunityUser.isEmpty()) {
            String result = createCommunityUsers(contactsWithoutCommunityUser);

            if (result != SUCCESS_STRING) {
                contacts[0].addError(result);
            }
        }

        if (!usersToUpdateByActiveStatus.isEmpty()) {
            System.enqueueJob(new UserUpdateQueue(usersToUpdateByActiveStatus));
        }
    }

    public String createCommunityUsers(List<Contact> contacts) {
        List<User> communityUsersToInsert = new List<User>();
        List<Profile> communityProfile = [SELECT Id FROM Profile WHERE Name = :DEFAULT_COMMUNITY_PROFILE_NAME];
        Map<Id, Contact> contactsWithAdditionalFields = new Map<Id, Contact>([
                SELECT Account.Owner.UserRoleId FROM Contact WHERE Id IN : contacts
        ]);

        for (Contact contact : contacts) {
            Contact contactWithAdditionalFields = contactsWithAdditionalFields.get(contact.Id);

            if (contact.AccountId != null && !communityProfile.isEmpty() && contactWithAdditionalFields.Account.Owner.UserRoleId != null) {
                User communityUser = new User();

                communityUser.FirstName = contact.FirstName;
                communityUser.LastName = contact.LastName;
                communityUser.ContactId = contact.Id;
                communityUser.Username = String.valueOf(contact.Id).substring(0, 6) + contact.Email;
                communityUser.Email = contact.Email;
                communityUser.CommunityNickname = contact.LastName.toLowerCase() + '_' + contact.FirstName.toLowerCase();
                String alias = contact.FirstName.toLowerCase().substring(0, 1) + contact.LastName.toLowerCase();
                communityUser.Alias = alias.length() > 8 ? (alias).substring(0, 7) : alias;
                communityUser.TimeZoneSidKey = 'America/Phoenix';
                communityUser.LocaleSidKey = 'en_US';
                communityUser.EmailEncodingKey = 'ISO-8859-1';
                communityUser.LanguageLocaleKey = 'en_US';
                communityUser.ProfileId = communityProfile[0].Id;

                communityUsersToInsert.add(communityUser);
            }
        }

        try {
            insert communityUsersToInsert;
        } catch (Exception e) {
            if (e.getTypeName() == System.DmlException.class.toString()) {
                return ((System.DmlException)e).getDmlMessage(0);
            } else {
                return e.getMessage();
            }
        }

        return SUCCESS_STRING;
    }
}