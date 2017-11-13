app.controller('navBarController', [ '$scope', '$localStorage', '$window','$http','$cookies',
    function($scope, $localStorage, $window, $http, $cookies) {

        $scope.username = $cookies.get('username');
        $(window).unload(function(){
            localStorage.removeItem(tab);
        });

        $scope.initializeBar = function(){
            $localStorage.tab = 1;
            console.log($localStorage.tab);
            $scope.select(1);
        };

        $scope.tab = $localStorage.tab;

        $scope.select = function(setTab) {
            $scope.tab = setTab;
            $localStorage.tab = $scope.tab;
            console.log("tab" + $scope.tab);
        };

        $scope.isSelected = function (checkTab) {
            return ($scope.tab === checkTab);
        };


    }]);