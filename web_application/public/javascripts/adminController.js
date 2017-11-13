"use strict"
app.controller('admincontroller',['$scope','$http','$state','$cookies',function ($scope,$http,$state,$cookies){

    $scope.control = "";
    $scope.adminValidate = function(){
       /* $http.post(
            host + 'api/v1/adminValidate',
            {
                username:$scope.username,
                password:$scope.password
            },
            { cors:true}
        )
            .success(function(data){

                if(data.statusCode == 200)
                {*/
                    $cookies.put('username',$scope.username);
                    $cookies.put('isadmin','admin');
                    $state.go('adminHome',{'test':$scope.username});
/*                }
                else
                {

                }

            })
            .error(function(data){
                console.log('error');
            })*/
    }
}]);