public without sharing class UserUpdateQueue implements Queueable {
    private Map<User, Boolean> usersToUpdateByActiveStatus;


    public UserUpdateQueue(Map<User, Boolean> usersToUpdateByActiveStatus) {
        this.usersToUpdateByActiveStatus = usersToUpdateByActiveStatus;
    }

    public void execute(QueueableContext context) {
        UserService.handleDeactivateUsers(usersToUpdateByActiveStatus);
    }
}