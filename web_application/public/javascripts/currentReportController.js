"use strict"
app.controller('currentReportController', [ '$state', '$scope', '$window','$http','$cookies',
    function($state, $scope, $window, $http, $cookies) {

        $scope.username = $cookies.get('username');

        $scope.getCurrentResult = function() {
            $http.post(

                'http://localhost:5000/api/v1/getUserCurrentReport',
                {
                    email_id: $cookies.get('username')
                },
                {cors: true}
            )
                .success(function (data) {
                    data = JSON.parse(data.userInfo);
                    $scope.predictedValue = data.classification;
                    $scope.accuracyValue = data.accuracy;
                    $scope.dateTaken = data.date_taken;
                    $scope.ModelValue = data.model_name;
                    console.log(data);
                }) .error(function (error) {
                console.log('error', JSON.stringify(error))
            })
        };
    }]);
