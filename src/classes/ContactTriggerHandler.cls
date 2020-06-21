public without sharing class ContactTriggerHandler extends SObjectDomain {

    ContactService contactServiceObject = new ContactService();

    public override void onBeforeInsert() {
        contactServiceObject.handleCreateCommunityUser((List<Contact>)this.records);
    }

    public override void onBeforeUpdate(Map<Id,SObject> existingRecords) {
        contactServiceObject.handleCreateCommunityUser((Map<Id, Contact>)existingRecords, (List<Contact>)this.records);
    }
}