
"use strict"
  app.controller('logincontroller',['$scope','$http','$state','$cookies',function ($scope, $http, $state, $cookies) {

      $scope.signIn = function () {

          /*      $http.post(
                            'http://localhost:5000/api/v1/validate',
                            {
                                username: $scope.username,
                                password: $scope.password
                            },
                            { cors: true }
                        )
                        .success(function(data){
                       if(data.statusCode == 200)
                           {*/
          $cookies.put('username', $scope.username);
          $state.go('about', {'test': $scope.username});
      }
      /*                 }
                        else
                        {
                        }
                    })
                    .error(function(error){
                          console.log('error')
                    })
            }*/
  }]);