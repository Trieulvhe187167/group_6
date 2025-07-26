<%@ page contentType="text/html" pageEncoding="UTF-8" %>
<%@ page import="model.CartItem" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>

    <head>
        <meta charset="UTF-8">
        <title>Your Cart</title>
               <link rel="icon" href="${pageContext.request.contextPath}/assets/images/favicon.ico" type="image/x-icon" />
        <link rel="shortcut icon" type="image/x-icon" href="${pageContext.request.contextPath}/assets/images/favicon.png" />

        <!-- All PLUGINS CSS -->
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/css/assets.css">
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/css/typography.css">
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/css/shortcodes/shortcodes.css">
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/css/style.css">
        <link class="skin" rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/css/color/color-1.css">

        <!-- Loading-->
        <script src="${pageContext.request.contextPath}/assets/js/jquery.min.js"></script>
        <script>
            $(window).on('load', function () {
                $('#loading-icon-bx').fadeOut();
            });
        </script>
     
    </head>
    <body id="bg">
        <div class="page-wraper">
   <!-- Spinner -->
        <div id="loading-icon-bx"></div>

            <!-- Header (Search + Cart + Menu) -->
            <header class="header rs-nav header-transparent">
                <%@ include file="header.jsp" %>
            </header>

        
            <div class="page-banner ovbl-dark" style="background-image:url(${pageContext.request.contextPath}/assets/images/banner/banner2.jpg);">
                <div class="container">
                    <div class="page-banner-entry">
                        <h1 class="text-white">Your Cart</h1>
                    </div>

                </div>
            </div>
            <div class="breadcrumb-row">
                <div class="container">
                    <ul class="list-inline">
                        <li><a href="${pageContext.request.contextPath}/index.jsp">Home</a></li>
                        <li>Cart</li>
                    </ul>
                </div>
            </div>


            <div class="container" style="min-height:400px;margin-top:30px;">
                <h3>Your Cart</h3>
                <%
                    List<CartItem> cart = (List<CartItem>) session.getAttribute("cart");
                    DecimalFormat df = new DecimalFormat("#,##0");
                %>
                <%
                    String ci = (String) session.getAttribute("lastSearchCheckIn");
                    String co = (String) session.getAttribute("lastSearchCheckOut");
                    String rt = (String) session.getAttribute("lastSearchRoomTypeId");
                    String cap = (String) session.getAttribute("lastSearchCapacity");
                    StringBuilder backUrl = new StringBuilder(request.getContextPath() + "/SearchAvailableRoomsServlet");
                    if (ci != null && co != null) {
                        backUrl.append("?checkIn=").append(ci).append("&checkOut=").append(co);
                        if (rt != null) backUrl.append("&roomTypeId=").append(rt);
                        if (cap != null) backUrl.append("&capacity=").append(cap);
                    }
                    String backUrlStr = backUrl.toString();
                %>
                <c:if test="${empty cart}">
                    <p>Your cart is empty.</p>
                    <a href="<%= backUrlStr %>" class="btn btn-secondary mt-2">Back Rooms to add </a>
                </c:if>
                <c:if test="${not empty cart}">
                    <p style="color: red">Will hold room for you for 10 minutes, please book and pay within this time!!</p>
                    <table class="table table-bordered">
                        <thead>
                            <tr>
                                <th>Room Type</th>
                                <th>Check-in</th>
                                <th>Check-out</th>
                                <th>Quantity</th>
                                <th>Price/night</th>
                                <th>Subtotal</th>
                                <th></th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if (cart != null) {
                                    int index = 0;
                                    double grandTotal = 0;
                                    for (CartItem item : cart) {
                                        java.time.LocalDate checkInDate = java.time.LocalDate.parse(item.getCheckIn());
                                        java.time.LocalDate checkOutDate = java.time.LocalDate.parse(item.getCheckOut());
                                        long nights = java.time.temporal.ChronoUnit.DAYS.between(checkInDate, checkOutDate);
                                        grandTotal += item.getPrice().doubleValue() * item.getQuantity() * nights;
                            %>
                            <tr>
                                <td><%= item.getRoomTypeName() %></td>
                                <td><%= item.getCheckIn() %></td>
                                <td><%= item.getCheckOut() %></td>
                                <td><%= item.getQuantity() %></td>
                                <td><%= df.format(item.getPrice()) %>₫</td>
                                <td><%= df.format(item.getPrice().multiply(new java.math.BigDecimal(item.getQuantity() * nights))) %>₫</td>
                                <td><a href="CartServlet?action=remove&index=<%= index %>" class="btn btn-sm btn-danger">Remove</a></td>
                            </tr>
                            <%
                                        index++;
                                    }
                            %>
                            <tr>
                                <td colspan="5" class="text-end"><strong>Total</strong></td>
                                <td colspan="2"><strong><%= df.format(grandTotal) %>₫</strong></td>
                            </tr>
                            <%
                                }
                            %>
                        </tbody>
                    </table>
                    <div class="d-flex justify-content-between">
                        <a href="<%= backUrlStr %>" class="btn btn-secondary">Back to Rooms</a>
                        <a href="${pageContext.request.contextPath}/jsp/booking.jsp" class="btn btn-primary">Proceed to Booking</a>
                    </div>
                </c:if>
            </div>
            <jsp:include page="footer.jsp" />
            <!-- Sticky Header on Scroll -->
            <script>
                (function ($) {
                    $(window).on('scroll', function () {
                        if ($(window).scrollTop() > 50) {
                            $('.sticky-header.navbar-expand-lg').addClass('is-fixed');
                        } else {
                            $('.sticky-header.navbar-expand-lg').removeClass('is-fixed');
                        }
                    });
                })(jQuery);
            </script>

    </body>
</html>