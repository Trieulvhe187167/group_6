<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>EduChamp : Education HTML Template</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="icon" href="../assets/images/favicon.ico" type="image/x-icon" />
    <link rel="shortcut icon" type="image/x-icon" href="../assets/images/favicon.png" />
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
            <a href="../index.html"><img src="../assets/images/logo-white-2.png" alt=""></a>
        </div>
        <div class="account-form-inner">
            <div class="account-container">
                <div class="heading-bx left">
                    <h2 class="title-head">Sign Up <span>Now</span></h2>
                    <p>Already have an account? <a href="Login.jsp">Click here</a></p>
                </div>	
                <form class="contact-bx" action="../RegisterServlet" method="post">
                    <div class="row placeani">
                        <div class="col-lg-12">
                            <div class="form-group">
                                <div class="input-group">
                                    <label>Your Name</label>
                                    <input name="name" type="text" required class="form-control">
                                </div>
                            </div>
                        </div>
                        <div class="col-lg-12">
                            <div class="form-group">
                                <div class="input-group">
                                    <label>Your Email Address</label>
                                    <input name="email" type="email" required class="form-control">
                                </div>
                            </div>
                        </div>
                        <div class="col-lg-12">
                            <div class="form-group">
                                <div class="input-group"> 
                                    <label>Your Password</label>
                                    <input name="password" type="password" required class="form-control">
                                </div>
                            </div>
                        </div>
                        <div class="col-lg-12">
                            <div class="form-group">
                                <div class="input-group">
                                    <label>Your Phone Number</label>
                                    <input name="phone" type="text" required class="form-control">
                                </div>
                            </div>
                        </div>
                        <div class="col-lg-12 m-b30">
                            <button type="submit" class="btn button-md">Sign Up</button>
                        </div>
                        <div class="col-lg-12">
                            <h6>Sign Up with Social media</h6>
                            <div class="d-flex">
                                <a class="btn flex-fill m-r5 facebook" href="#"><i class="fa fa-facebook"></i>Facebook</a>
                                <a class="btn flex-fill m-l5 google-plus" href="#"><i class="fa fa-google-plus"></i>Google Plus</a>
                            </div>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<!-- JS -->
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
