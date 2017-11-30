"use strict"
app.controller('signupcontroller',['$state', '$scope','$http',function ($state, $scope, $http){

    $scope.errorhide = true;
    $scope.addNewUser = function(){
        $http.post(
            'https://flask-upload-app.herokuapp.com/api/v1/register',
            {
                username : $scope.new_user,
                email_id : $scope.new_email,
                password: $scope.new_password
            },
            { cors:true}
        )
            .success(function(data){
                console.log("Data" + JSON.stringify(data));
                if(data.statusCode == 200)
                {
                    $state.go('login')
                }
                else
                {
                    $scope.errorhide = false;
                    console.log('error')
                }

            })
            .error(function(error){
                $scope.errorhide = false;
                console.log('error' + JSON.stringify(error));
            });

    }

}]);