class SERVERURL {
    /* Define all server URLS here
     * Do not copy paste the base, use the variable to extend it to avoid errors
     * All mobile API endpoints start with `/m/`
     */
    static const String BASE = 'https://gymder.appspot.com';
    static const String LOGIN = SERVERURL.BASE + '/m/login/';
    static const String AUTHENTICATION_PING = SERVERURL.BASE + '/m/auth/';

    static const String USER_ACTIVITIES = SERVERURL.BASE + '/m/activities/';

    static const String ACTIVITY_REQUEST_PREFIX = SERVERURL.BASE + '/api/activities/';
    static const String ACTIVITY_REQUEST_SUFFIX = '/requests/';
}