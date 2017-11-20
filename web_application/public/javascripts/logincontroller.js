"use strict"
app.controller('logincontroller', ['$scope', '$http', '$state', '$cookies', function ($scope, $http, $state, $cookies) {

    $scope.host = "http://0.0.0.0:5000";
    $scope.signIn = function () {

        $http.post(
            'http://localhost:5000/api/v1/validate',
            {
                email_id: $scope.email_id,
                password: $scope.password
            },
            {cors: true}
        )
            .success(function (data) {
                if (data.statusCode == 200) {
                    $cookies.put('username', $scope.email_id);
                    $state.go('about', {'test': $scope.email_id});
                } else {
                    console.log("error");
                }
            }) .error(function (error) {
                console.log('error', JSON.stringify(error))
            })
    }
}]);