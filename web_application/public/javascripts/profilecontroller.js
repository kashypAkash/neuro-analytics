
"use strict"
  app.controller('profilecontroller',['$scope','$http','$state','$cookies',function ($scope,$http,$state,$cookies){

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
                  location: $scope.location,
                  username: $cookies.get('username')
              },
              {cors: true}
          )
              .success(function (data) {
                  if (data.statusCode == 200) {
                      $cookies.put('username', $scope.username);
                      $state.go('about', {'test': $scope.username});
                  } else {
                      console.log("error");
                  }
              }) .error(function (error) {
              console.log('error', JSON.stringify(error))
          })
      }
      
  }]);