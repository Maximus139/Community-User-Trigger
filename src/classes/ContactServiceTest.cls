@IsTest
public without sharing class ContactServiceTest {

    @TestSetup
    private static void setup() {
        Account account = new Account();

        account.Name = 'Test Account';

        insert account;

        Contact contact = new Contact();

        contact.FirstName = 'Max';
        contact.LastName = 'Test';
        contact.Email =  'testemail@gmail.com';
        contact.Is_Customer__c = false;
        contact.AccountId = account.Id;

        insert contact;
    }

    @IsTest
    private static void handleCreateCommunityUserTestCorrectFlow() {
        List<Contact> contacts = [SELECT Id, Is_Customer__c FROM Contact];

        if (!contacts.isEmpty()) {
            contacts[0].Is_Customer__c = true;

            Test.startTest();
            update contacts;
            Test.stopTest();

            List<User> communityUsers = [SELECT Id FROM User WHERE ContactId IN :contacts];

            System.assert(!communityUsers.isEmpty());
        }
    }

    @IsTest
    private static void handleCreateCommunityUserTestCorrectFlowReactivateUser() {
        List<Contact> contacts = [SELECT Id, Is_Customer__c FROM Contact];

        if (!contacts.isEmpty()) {
            contacts[0].Is_Customer__c = true;

            Test.startTest();
            update contacts;
            contacts[0].Is_Customer__c = false;
            update contacts;
            contacts[0].Is_Customer__c = true;
            update contacts;
            Test.stopTest();

            List<User> communityUsers = [SELECT Id, IsActive FROM User WHERE ContactId IN :contacts];

            System.assert(communityUsers[0].IsActive);
        }
    }
}