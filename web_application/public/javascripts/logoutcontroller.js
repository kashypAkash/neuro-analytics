
"use strict"
  app.controller('logoutcontroller',['$scope','$http','$state','$cookies',function ($scope,$http,$state,$cookies){

    $cookies.remove('username');
      $state.go('login')
      
  }])