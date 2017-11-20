"use strict"
app.controller('viewAllUsersController', [ '$state', '$scope', '$window','$http','$cookies',
    function($state, $scope, $window, $http, $cookies) {

        $scope.username = $cookies.get('username');

        $scope.getUsers = function() {
            $http.post(
                'http://localhost:5000/api/v1/getAllUsers',
                {
                    email_id: $cookies.get('username')
                },
                {cors: true}
            )
                .success(function (data) {
                    console.log(data);
                    $scope.users = data.users;
                }) .error(function (error) {
                console.log('error', JSON.stringify(error))
            })
        };

       $scope.viewUserReports =  function(username) {
           $http.post(
               'http://localhost:5000/api/v1/getUserReports',
               {
                   email_id: $scope.email_id
               },
               {cors: true}
           )
               .success(function (data) {
                   $scope.reports =  data.reports;
                   console.log($scope.reports);
               }) .error(function (error) {
               console.log('error', JSON.stringify(error))
           })
       }

        $scope.viewReport =  function(report) {
            $scope.selectedReport = report;
        }
    }]);