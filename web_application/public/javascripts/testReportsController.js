"use strict"
app.controller('testReportsController', [ '$state', '$scope', '$window','$http','$cookies',
    function($state, $scope, $window, $http, $cookies) {

        $scope.username = $cookies.get('username');
        $scope.getUserReports = function() {
            $http.post(

                'http://localhost:5000/api/v1/getUserReports',
                {
                    username: $cookies.get('username')
                },
                {cors: true}
            )
                .success(function (data) {
                    $scope.reports =  data.reports;
                    console.log($scope.reports);
                }) .error(function (error) {
                console.log('error', JSON.stringify(error))
            })
        };

        $scope.viewReport =  function(report) {
            $scope.selectedReport = report;
        }
    }]);