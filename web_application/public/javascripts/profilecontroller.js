
"use strict"
  app.controller('profilecontroller',['$scope','$http','$state','$cookies',function ($scope,$http,$state,$cookies){

      $scope.getUserDetails = function() {
          console.log("entered");
          $http.post(

              'http://localhost:5000/api/v1/getUserDetails',
              {
                  email_id: $cookies.get('username')
              },
              {cors: true}
              )
              .success(function (data) {
                  data = JSON.parse(data.userInfo);
                  $scope.name = data.name;
                  $scope.gender = data.gender;
                  $scope.email_id = data.email_id;
                  $scope.password = data.password;
                  $scope.date_of_birth = data.date_of_birth;
                  $scope.location = data.location;
                  $scope.telephone = data.telephone;
              }) .error(function (error) {
              console.log('error', JSON.stringify(error))
          })
      };

      $scope.updateProfile = function () {
          $http.post(

              'http://localhost:5000/api/v1/updateProfile',
              {
                  name: $scope.name,
                  gender: $scope.gender,
                  password: $scope.password,
                  email_id: $scope.email_id,
                  date_of_birth: $scope.date_of_birth,
                  telephone: $scope.telephone,
                  location: $scope.location
              },
              {cors: true}
          )
              .success(function (data) {

              }) .error(function (error) {
              console.log('error', JSON.stringify(error))
          })
      }
      
  }]);