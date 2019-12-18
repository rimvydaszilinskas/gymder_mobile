import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:model/models/activity.dart';
import 'package:model/models/user.dart';
import 'package:model/pages/activities/create.dart';
import 'package:model/pages/activities/preview.dart';
import 'package:model/pages/activities/searchResults.dart';
import 'package:model/pages/group.dart';
import 'package:model/pages/groups.dart';
import 'package:model/pages/profile.dart';
import 'package:model/pages/register.dart';

class Router {
    /* Application router
     * Define custom routes here and what data is required to be passeds
     */
    static Route<dynamic> generateRoute(RouteSettings settings) {
        switch(settings.name) {
            case '/register':
                var data = settings.arguments as String;
                return MaterialPageRoute(builder: (_) => RegisterPage());
            case '/profile':
                var data = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(builder: (_) => ProfilePreview(data['user']));
            case '/activity':
                var data = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(builder: (_) => ActivityPreview(data['activity'], data['user']));
            case '/activity/results':
                var data = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(builder: (_) => SearchResultList(data['activities'], data['user']));
            case '/activity/create':
                var data = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(builder: (_) => CreateActivity(data['user']));
            case '/groups':
                var data = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(builder: (_) => GroupList(data['user']));
            case '/group':
                var data = settings.arguments as Map<String, dynamic>;
                return MaterialPageRoute(builder: (_) => GroupPreview(data['group'], data['user']));
            default:
                return MaterialPageRoute(builder: (_) => Scaffold());
        }
    }
}