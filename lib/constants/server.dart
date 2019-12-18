class SERVERURL {
    /* Define all server URLS here
     * Do not copy paste the base, use the variable to extend it to avoid errors
     * All mobile API endpoints start with `/m/`
     */
    static const String BASE = 'https://gymder.appspot.com';
    static const String LOGIN = SERVERURL.BASE + '/m/login/';
    static const String AUTHENTICATION_PING = SERVERURL.BASE + '/m/auth/';

    static const String USER_ACTIVITIES = SERVERURL.BASE + '/m/activities/';
    static const String SEARCH_ACTIVITIES = SERVERURL.BASE + '/api/activities/';
    static const String NEARBY_ACTIVITIES = SERVERURL.BASE + '/api/activities/nearby/';

    static const String INDIVIDUAL_ACTIVITIES = SEARCH_ACTIVITIES + 'individual/';
    static const String GROUP_ACTIVITIES = SEARCH_ACTIVITIES + 'group/';

    static const String ACTIVITY_REQUEST_PREFIX = SERVERURL.BASE + '/api/activities/';
    static const String ACTIVITY_REQUEST_SUFFIX = '/requests/';

    static const String VERIFY_ADDRESS = SERVERURL.BASE + '/api/utils/addresses/';

    static const String USER = SERVERURL.BASE + '/api/user/';
    static const String USER_GROUPS = SERVERURL.BASE + '/api/groups/';

    static const String GROUP_PREFIX = SERVERURL.USER_GROUPS;
    static const String GROUP_ACTIVITIES_SUFFIX = '/activities/';
    static const String GROUP_MEMBERSHIP_SUFFIX = '/memberships/';
}