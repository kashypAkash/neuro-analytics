app.controller('navBarController', [ '$state', '$scope', '$localStorage', '$window','$http','$cookies',
    function($state, $scope, $localStorage, $window, $http, $cookies) {

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

        $scope.logout = function(){
            console.log("here");
            $cookies.remove('username');
            $state.go('login')
        }
    }]);