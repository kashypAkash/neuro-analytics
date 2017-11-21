"use strict"
app.controller('admincontroller',['$scope','$http','$state','$cookies',function ($scope,$http,$state,$cookies){

    $scope.control = "";
    $scope.adminValidate = function(){
        console.log("In admin controller");
        $http.post(
             'https://flask-upload-app.herokuapp.com/api/v1/adminValidate',
            {
                email_id:$scope.email_id,
                password:$scope.password
            },
            { cors:true}
            )
            .success(function(data){
                if(data.statusCode == 200)
                {
                    $cookies.put('username',$scope.email_id);
                    $cookies.put('isadmin','admin');
                    $state.go('adminHome',{'test':$scope.email_id});
               }
                else
                {

                }

            })
            .error(function(data){
                console.log('error');
            })
    }
}]);