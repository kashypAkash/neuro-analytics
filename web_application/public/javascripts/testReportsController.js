"use strict"
app.controller('testReportsController', [ '$state', '$scope', '$window','$http','$cookies',
    function($state, $scope, $window, $http, $cookies) {

        $scope.username = $cookies.get('username');
        $scope.getUserReports = function() {
            $http.post(

                'https://flask-upload-app.herokuapp.com/api/v1/getUserReports',
                {
                    email_id: $cookies.get('username')
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

        $scope.minute = [1,2,3,4,5];
        $scope.price = [ 22,23,4,5,6]
        Highcharts.chart('container', {

            xAxis: {
                categories:$scope.minute
            },

            series: [{
                data: $scope.price
            }]
        });
    }]);