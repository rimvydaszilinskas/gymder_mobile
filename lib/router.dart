import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
            default:
                return MaterialPageRoute(builder: (_) => Scaffold());
        }
    }
}