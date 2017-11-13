/**
 * Created by akash on 8/14/16.
 */
"use strict"
 var app = angular.module('spa',['chart.js','ui.router','ui.bootstrap','ngCookies', 'ngStorage']);
    app.config(function($stateProvider, $urlRouterProvider){

        $urlRouterProvider.otherwise('/');

        $stateProvider
            .state('login', {
                url: '/',
                views: {
                    'main@':{
                        templateUrl: 'login.ejs',
                        controller:'logincontroller'
                    }
                }

            })
            .state('admin', {
                url: "/admin",
                views:{
                    'main@':{
                        templateUrl: 'adminlogin.ejs',
                        controller:'admincontroller'
                    }
                }
            })
            .state('signup', {
                url: "/signup",
                views:{
                    'main@':{
                        templateUrl: 'signup.ejs',
                        controller:'signupcontroller'
                    }
                }
            })
            .state('about', {
                url: "/about",
                views:{
                    'navbar@':{
                        templateUrl: 'navbar.ejs',
                        controller: 'navBarController'
                    },
                    'sidemenu@':{
                        templateUrl: 'sidebarView.ejs',
                        controller: 'navBarController'
                    },
                    'main@':{
                        templateUrl: 'about.ejs'
                    }
                },
                params: { test: "default value" }
            })
            .state('profile', {
                url: "/profile",
                views:{
                    'navbar@':{
                        templateUrl: 'navbar.ejs',
                        controller: 'navBarController'
                    },
                    'sidemenu@':{
                        templateUrl: 'sidebarView.ejs',
                        controller: 'navBarController'
                    },
                    'main@':{
                        templateUrl: 'profile.ejs',
                        controller : 'profilecontroller'
                    }
                },
                params: { test: "default value" }
            })
            .state('adminprofile', {
                url: "/adminprofile",
                views:{
                    'main@':{
                        templateUrl: 'profile.ejs',
                        controller : 'profilecontroller'
                    }
                },
                params: { test: "default value" }
            });
    });
