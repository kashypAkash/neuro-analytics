"use strict"
app.controller('dashboardController', [ '$state', '$scope', '$window','$http','$cookies',
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

            $scope.drawGraphs();
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

        $scope.drawGraphs =  function() {
            $http.get(
                'http://ec2-18-217-79-183.us-east-2.compute.amazonaws.com/stat/all_data',
                {cors: true}
            )
                .success(function (data) {
                    console.log(data);

                    $scope.healthy_data = [];
                    $scope.unhealthy_data = [];
                    $scope.user_data_values = [];

                    for(var  i= 0; i < data.length; i++) {
                        if(data[i]['class'] == "Healthy") {
                            var healthy_temp = [];
                            healthy_temp.push(data[i]['xyz_mean']);
                            healthy_temp.push(data[i]['xyz_PSD_6_sd'])
                            $scope.healthy_data.push(healthy_temp);
                        } else if (data[i]['class'] == "Parkinson's") {
                            var unhealthy_temp = [];
                            unhealthy_temp.push(data[i]['xyz_mean']);
                            unhealthy_temp.push(data[i]['xyz_PSD_6_sd']);
                            $scope.unhealthy_data.push(unhealthy_temp);
                        }
                    }

                    var user_data = $scope.reportData;

                    for(var i =0; i < user_data.length; i++) {
                        var user_data_temp = [];
                        user_data_temp.push(user_data[i]['xyz_mean']);
                        user_data_temp.push(user_data[i]['xyz_PSD_6_sd']);
                        $scope.user_data_values.push(user_data_temp);
                    }

                    Highcharts.chart('container1', {
                        chart: {
                            type: 'scatter',
                            zoomType: 'xy'
                        },
                        title: {
                            text: 'Comparision of important features with other users'
                        },
                        xAxis: {
                            title: {
                                enabled: true,
                                text: 'xyz_mean'
                            },
                            startOnTick: true,
                            endOnTick: true,
                            showLastLabel: true
                        },
                        yAxis: {
                            title: {
                                text: 'xyz_psd_6_sd'
                            }
                        },
                        legend: {
                            layout: 'vertical',
                            align: 'left',
                            verticalAlign: 'top',
                            x: 100,
                            y: 70,
                            floating: true,
                            backgroundColor: (Highcharts.theme && Highcharts.theme.legendBackgroundColor) || '#FFFFFF',
                            borderWidth: 1
                        },
                        plotOptions: {
                            scatter: {
                                marker: {
                                    radius: 5,
                                    states: {
                                        hover: {
                                            enabled: true,
                                            lineColor: 'rgb(100,100,100)'
                                        }
                                    }
                                },
                                states: {
                                    hover: {
                                        marker: {
                                            enabled: false
                                        }
                                    }
                                },
                                tooltip: {
                                    headerFormat: '<b>{series.name}</b><br>',
                                    pointFormat: '{point.x} cm, {point.y} kg'
                                }
                            }
                        },
                        series: [{
                            name: 'Healthy',
                            color: 'rgba(223, 83, 83, .5)',
                            data: $scope.healthy_data

                        }, {
                            name: 'Parkinsons',
                            color: 'rgba(119, 152, 191, .5)',
                            data: $scope.unhealthy_data
                        }, {
                            name: 'User Data',
                            color: 'rgba(30, 223, 84, .5)',
                            data: $scope.user_data_values
                        },
                        ]
                    });


                }) .error(function (error) {
                console.log('error', JSON.stringify(error))
            })
        };






    }]);