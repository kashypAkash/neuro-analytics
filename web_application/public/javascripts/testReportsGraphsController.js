"use strict"
app.controller('testReportsGraphsController', [ '$state', '$scope', '$window','$http','$cookies',
    function($state, $scope, $window, $http, $cookies) {

        $scope.username = $cookies.get('username');

        $scope.reportFeatures = ["xyz_mean", "xyz_absolute_deviation","xyz_standard_deviation",
        "xyz_max_deviation", "xyz_PSD_1", "xyz_PSD_1_sd", "xyz_PSD_3", "xyz_PSD_3_sd",
            "xyz_PSD_6", "xyz_PSD_6_sd", "xyz_PSD_10", "xyz_PSD_10_sd", "xyz_absolute_deviation",
            "xyz_max_deviation", "xyz_mean", "xyz_mean_sd", "xyz_standard_deviation"
        ];

        $scope.getUserReports = function() {
            $http.post(

                'https://flask-upload-app.herokuapp.com/api/v1/getUserReports',
                {
                    email_id: $cookies.get('username')
                },
                {cors: true}
            )
                .success(function (data) {
                    $scope.reports =  data.reports;
                    console.log($scope.reports);
                }) .error(function (error) {
                console.log('error', JSON.stringify(error))
            })
        };

        $scope.viewReport =  function(report) {
            $scope.selectedReport = report;
            $http.get(

                'http://ec2-18-217-79-183.us-east-2.compute.amazonaws.com/stat/data?email_id=' +
                $cookies.get('username') +'&result_id=' + report.id,

                {cors: true}
            )
                .success(function (data) {
                    $scope.reportData = data;

                    console.log(data[0]);
                    $scope.reportDates = [];
                    var report_dates_u= {};

                    for(var i =0; i < data.length; i++) {
                        if(!report_dates_u.hasOwnProperty(data[i].date)) {
                            $scope.reportDates.push(data[i].date);
                            report_dates_u[data[i].date] = 1;
                        }
                    }

                    console.log($scope.reportDates);


                }) .error(function (error) {
                console.log('error', JSON.stringify(error))
            })
        };

        $scope.getHour = function(date) {
            var data = $scope.reportData;
            $scope.reportDateHours = [];
            var report_dates_hours_u= {};

            for(var i =0; i < data.length; i++) {
                if(data[i].date == date && !report_dates_hours_u.hasOwnProperty(data[i].hour)) {
                    $scope.reportDateHours.push(data[i].hour);
                    report_dates_hours_u[data[i].hour] = 1;
                }
            }

            console.log($scope.reportDateHours);

        };

        $scope.drawGraph = function(feature) {

            console.log(feature + ";" +  $scope.reportDateSelected + ";" + $scope.reportDateHourSelected);

            var data = $scope.reportData;

            $scope.featureValues = [];
            $scope.minuteValues = [];
            for(var i=0; i < data.length; i++) {
                if(data[i].date == $scope.reportDateSelected && data[i].hour == $scope.reportDateHourSelected ) {
                    $scope.featureValues.push(data[i][feature]);
                    $scope.minuteValues.push(data[i]['minute']);
                }
            }


            Highcharts.chart('container', {
                title: {
                    text: feature + ' values based on minutes'
                },
                xAxis: {
                    title: {
                        text: 'Minute'
                    },
                    categories:$scope.minuteValues
                },

                yAxis: {
                    title: {
                        text: feature
                    }
                },

                series: [{
                    data: $scope.featureValues
                }]
            });
        };



    }]);