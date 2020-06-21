trigger ContactTrigger on Contact (before insert, before update, before delete, after insert, after update, after delete, after undelete) {

    List<Trigger_Setting__mdt> tr = [
            SELECT is_Active__c
            FROM Trigger_Setting__mdt
            WHERE DeveloperName = 'Contact_Trigger'
    ];

    if (tr.isEmpty() || tr[0].is_Active__c == true) {
        SObjectDomain.triggerHandler(ContactTriggerHandler.class);
    }
}