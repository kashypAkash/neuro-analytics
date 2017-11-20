"use strict"
app.controller('signupcontroller',['$state', '$scope','$http',function ($state, $scope, $http){

    $scope.addNewUser = function(){
        $http.post(
            'http://localhost:5000/api/v1/register',
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
                    console.log('error')
                }

            })
            .error(function(error){
                console.log('error' + JSON.stringify(error));
            });

    }

}]);