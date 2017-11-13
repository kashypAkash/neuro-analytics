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
            .state('adminHome', {
                url: "/adminHome",
                views:{
                    'navbar@':{
                        templateUrl: 'navbar.ejs',
                        controller: 'navBarController'
                    },
                    'sidemenu@':{
                        templateUrl: 'adminSidebarViewPage.ejs',
                        controller: 'navBarController'
                    },
                    'main@':{
                        templateUrl: 'adminHome.ejs',
                        controller : 'adminHomeController'
                    }
                },
                params: { test: "default value" }
            })
            .state('viewusers', {
                url: "/viewUsers",
                views:{
                    'navbar@':{
                        templateUrl: 'navbar.ejs',
                        controller: 'navBarController'
                    },
                    'sidemenu@':{
                        templateUrl: 'adminSidebarViewPage.ejs',
                        controller: 'navBarController'
                    },
                    'main@':{
                        templateUrl: 'viewusers.ejs',
                        controller : 'viewUsersController'
                    }
                },
                params: { test: "default value" }
            })
            .state('viewallusers', {
                url: "/viewAllUsers",
                views:{
                    'navbar@':{
                        templateUrl: 'navbar.ejs',
                        controller: 'navBarController'
                    },
                    'sidemenu@':{
                        templateUrl: 'adminSidebarViewPage.ejs',
                        controller: 'navBarController'
                    },
                    'main@':{
                        templateUrl: 'viewallusers.ejs',
                        controller : 'viewAllUsersController'
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
            .state('currentreport', {
                url: "/currentReport",
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
                        templateUrl: 'currentReport.ejs',
                        controller : 'currentReportController'
                    }
                },
                params: { test: "default value" }
            })
            .state('testReports', {
                url: "/testReports",
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
                        templateUrl: 'allReports.ejs',
                        controller : 'testReportsController'
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
