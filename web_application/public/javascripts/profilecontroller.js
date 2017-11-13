
"use strict"
  app.controller('profilecontroller',['$scope','$http','$state','$cookies',function ($scope,$http,$state,$cookies){

    if($cookies.get('username') ==undefined || $cookies.get('username') =='' || $cookies.get('username') == null){
        //$state.go('admin')


    }
    else
    {

        $scope.test = $state.params.test;
        $scope.user = $cookies.get('username');

        $scope.logout = function(){
            $cookies.remove('username');
            $state.go('login')
        }
    }

      $scope.labels = ["January", "February", "March", "April", "May", "June", "July"];
      $scope.series = ['Series A', 'Series B'];
      $scope.data = [
          [65, 59, 80, 81, 56, 55, 40],
          [28, 48, 40, 19, 86, 27, 90]
      ];
      $scope.onClick = function (points, evt) {
          console.log(points, evt);
      };
      $scope.datasetOverride = [{ yAxisID: 'y-axis-1' }, { yAxisID: 'y-axis-2' }];
      $scope.options = {
          scales: {
              yAxes: [
                  {
                      id: 'y-axis-1',
                      type: 'linear',
                      display: true,
                      position: 'left'
                  },
                  {
                      id: 'y-axis-2',
                      type: 'linear',
                      display: true,
                      position: 'right'
                  }
              ]
          }
      };
      
  }])