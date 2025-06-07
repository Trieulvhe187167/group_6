<%@ page contentType="text/html; charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="keywords" content="" />
    <meta name="author" content="" />
    <meta name="robots" content="" />

    <!-- DESCRIPTION -->
    <meta name="description" content="LuxuryHotel : Hotel HTML Template" />
    <meta property="og:title" content="LuxuryHotel : Hotel HTML Template" />
    <meta property="og:description" content="LuxuryHotel : Hotel HTML Template" />
    <meta property="og:image" content="" />
    <meta name="format-detection" content="telephone=no">

    <link rel="icon" href="../assets/images/favicon.ico" type="image/x-icon" />
    <link rel="shortcut icon" type="image/x-icon" href="../assets/images/favicon.png" />
    <title>LuxuryHotel : Reset Password</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <link rel="stylesheet" type="text/css" href="../assets/css/assets.css">
    <link rel="stylesheet" type="text/css" href="../assets/css/typography.css">
    <link rel="stylesheet" type="text/css" href="../assets/css/shortcodes/shortcodes.css">
    <link rel="stylesheet" type="text/css" href="../assets/css/style.css">
    <link class="skin" rel="stylesheet" type="text/css" href="../assets/css/color/color-1.css">
</head>

<body id="bg">
    <div class="page-wraper">
        <div id="loading-icon-bx"></div>
        <div class="account-form">
            <div class="account-head" style="background-image:url(../assets/images/background/bg2.jpg);">
                <a href="../index.jsp"><img src="../assets/images/logo-white-2.png" alt=""></a>
            </div>
            <div class="account-form-inner">
                <div class="account-container">
                    <div class="heading-bx left">
                        <h2 class="title-head">Forget <span>Password</span></h2>
                        <p>Login Your Account <a href="/jsp/login.jsp">Click here</a></p>
                    </div>

                    <!-- THÔNG BÁO -->
                    <%
                        String msg = (String) request.getAttribute("msg");
                        if (msg != null) {
                    %>
                        <div class="alert alert-info"><%= msg %></div>
                    <%
                        }
                    %>

                    <!-- FORM GỬI EMAIL -->
                        <form class="contact-bx" action="${pageContext.request.contextPath}/forgot-password" method="post">
                        <div class="row placeani">
                            <div class="col-lg-12">
                                <div class="form-group">
                                    <div class="input-group">
                                        <input name="email" type="email" required class="form-control" placeholder="Enter your email">
                                    </div>
                                </div>
                            </div>
                            <div class="col-lg-12 m-b30">
                                <button name="submit" type="submit" value="Submit" class="btn button-md">Submit</button>
                            </div>
                        </div>
                    </form>

                </div>
            </div>
        </div>
    </div>

    <script src="../assets/js/jquery.min.js"></script>
    <script src="../assets/vendors/bootstrap/js/popper.min.js"></script>
    <script src="../assets/vendors/bootstrap/js/bootstrap.min.js"></script>
    <script src="../assets/vendors/bootstrap-select/bootstrap-select.min.js"></script>
    <script src="../assets/vendors/bootstrap-touchspin/jquery.bootstrap-touchspin.js"></script>
    <script src="../assets/vendors/magnific-popup/magnific-popup.js"></script>
    <script src="../assets/vendors/counter/waypoints-min.js"></script>
    <script src="../assets/vendors/counter/counterup.min.js"></script>
    <script src="../assets/vendors/imagesloaded/imagesloaded.js"></script>
    <script src="../assets/vendors/masonry/masonry.js"></script>
    <script src="../assets/vendors/masonry/filter.js"></script>
    <script src="../assets/vendors/owl-carousel/owl.carousel.js"></script>
    <script src="../assets/js/functions.js"></script>
    <script src="../assets/js/contact.js"></script>
    <script src="../assets/vendors/switcher/switcher.js"></script>
</body>

</html>
