"use strict"
app.controller('logincontroller', ['$scope', '$localStorage', '$http', '$state', '$cookies',
    function ($scope, $localStorage, $http, $state, $cookies) {

    $scope.errorhide = true;
    $scope.host = "http://0.0.0.0:5000";
    $scope.signIn = function () {

        $http.post(
            'https://flask-upload-app.herokuapp.com/api/v1/validate',
            {
                email_id: $scope.email_id,
                password: $scope.password
            },
            {cors: true}
        )
            .success(function (data) {
                if (data.statusCode == 200) {
                    $cookies.put('username', $scope.email_id);
                    $state.go('dashboard', {'test': $scope.email_id});
                } else {
                    $scope.errorhide = false;
                    console.log("error");
                }
            }) .error(function (error) {
                $scope.errorhide = false;
                console.log('error', JSON.stringify(error))
            })
    }
}]);