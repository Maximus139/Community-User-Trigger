public without sharing class UserService {

    public static void handleDeactivateUsers(Map<User, Boolean> usersToUpdateByActiveStatus) {
        for (User user : usersToUpdateByActiveStatus.keySet()) {
            user.IsActive = usersToUpdateByActiveStatus.get(user);
        }

        update new List<User>(usersToUpdateByActiveStatus.keySet());
    }
}