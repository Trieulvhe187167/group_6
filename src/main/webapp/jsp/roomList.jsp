<%-- 
    Document   : roomList.jsp
    Created on : 23 thg 5, 2025, 11:43:18
    Author     : ASUS
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="model.RoomType" %>
<%@ page import="java.util.List" %>


<!DOCTYPE html>
<html>
    <head>
        <!--        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">-->
        <!-- META ============================================= -->
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="keywords" content="" />
        <meta name="author" content="" />
        <meta name="robots" content="" />

        <!-- DESCRIPTION -->
        <meta name="description" content="EduChamp : Education HTML Template" />

        <!-- OG -->
        <meta property="og:title" content="EduChamp : Education HTML Template" />
        <meta property="og:description" content="EduChamp : Education HTML Template" />
        <meta property="og:image" content="" />
        <meta name="format-detection" content="telephone=no">

        <!-- FAVICONS ICON ============================================= -->
        <link rel="icon" href="${pageContext.request.contextPath}/assets/images/favicon.ico" type="image/x-icon" />
        <link rel="shortcut icon" type="image/x-icon" href="${pageContext.request.contextPath}/assets/images/favicon.png" />

        <!-- PAGE TITLE HERE ============================================= -->
        <title>LuxuryHotel | List of Room </title>

        <!-- MOBILE SPECIFIC ============================================= -->
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <!--[if lt IE 9]>
        <script src="assets/js/html5shiv.min.js"></script>
        <script src="assets/js/respond.min.js"></script>
        <![endif]-->

        <!-- All PLUGINS CSS ============================================= -->
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/css/assets.css">

        <!-- TYPOGRAPHY ============================================= -->
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/css/typography.css">

        <!-- SHORTCODES ============================================= -->
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/css/shortcodes/shortcodes.css">

        <!-- STYLESHEETS ============================================= -->
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/css/style.css">
        <link class="skin" rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/css/color/color-1.css">


    </head>
    <body id="bg">
        <div class="page-wraper">
            <div id="loading-icon-bx"></div>

            <!-- Header Top ==== -->
            <jsp:include page="header.jsp" />
            <!-- header END ==== -->
            
            <!-- Content -->
            <div class="page-content bg-white">
                <!-- inner page banner -->
                <div class="page-banner ovbl-dark" style="background-image:url('${pageContext.request.contextPath}/assets/images/banner/banner2.jpg');">
                    <div class="container">
                        <div class="page-banner-entry">
                            <h1 class="text-white">Room List</h1>
                        </div>
                    </div>
                </div>
                <!-- Breadcrumb row -->
                <div class="breadcrumb-row">
                    <div class="container">
                        <ul class="list-inline">
                            <li><a href="#">Home</a></li>
                            <li>RoomList</li>
                        </ul>
                    </div>
                </div>
                <!-- Breadcrumb row END -->
                <!-- inner page banner END -->
                <div class="content-block">
                    <!-- About Us -->
                    <div class="section-area section-sp1">
                        <div class="container">
                            <div class="row">
                                <div class="col-lg-3 col-md-4 col-sm-12 m-b30">
                                    <a href="jsp/create-roomtype.jsp" class="btn ">Create Type</a>
                                    <div class="widget courses-search-bx placeani">
                                        <div class="form-group">
                                            <form action="RoomListServlet" method="get">
                                                <div class="input-group">
                                                    <label>Search Rooms</label>
                                                    <input name="keyword" type="text" required class="form-control"><br><br>
                                                    <button type="submit" class="btn ">Search</button>
                                                </div>
                                            </form>
                                        </div>
                                    </div>
                                    <div class="widget widget_archive">
                                        <h5 class="widget-title style-1">All Courses</h5>
                                        <form action="RoomListServlet" method="get" style="display: flex; flex-direction: column; gap: 10px;">
                                            <select name="price" class="form-select" style="height: 40px;">
                                                <option value="">-- Filter by Price --</option>
                                                <option value="1" ${selectedPrice == '1' ? 'selected' : ''}>Under 500k</option>
                                                <option value="2" ${selectedPrice == '1' ? 'selected' : ''}>500k - 1M</option>
                                                <option value="3" ${selectedPrice == '1' ? 'selected' : ''}>Over 1M</option>
                                            </select>

                                            <select name="capacity" class="form-select" style="height: 40px;">
                                                <option value="">-- Filter by Capacity --</option>
                                                <option value="1" ${selectedCapacity == '1' ? 'selected' : ''}>1 Person</option>
                                                <option value="2" ${selectedCapacity == '2' ? 'selected' : ''}>2 People</option>
                                                <option value="3" ${selectedCapacity == '3' ? 'selected' : ''}>3 or more</option>
                                            </select>

                                            <select name="status" class="form-select" style="height: 40px;">
                                                <option value="">-- Filter by Status --</option>
                                                <option value="active" ${selectedStatus == 'active' ? 'selected' : ''}>Available</option>
                                                <option value="inactive" ${selectedStatus == 'inactive' ? 'selected' : ''}>Unavailable</option>
                                            </select>

                                            <button type="submit" class="btn btn-primary" style="height: 40px;">Filter</button>
                                        </form>
                                    </div>

                                    <div class="widget">

                                        <a href="#"><img src="assets/images/adv/adv.jpg" alt=""/></a>
                                    </div>
                                    <div class="widget recent-posts-entry widget-courses">
                                        <h5 class="widget-title style-1">Recent Courses</h5>
                                        <div class="widget-post-bx">
                                            <div class="widget-post clearfix">
                                                <div class="ttr-post-media"> <img src="${pageContext.request.contextPath}/assets/images/blog/recent-blog/pic1.jpg" width="200" height="143" alt=""> </div>
                                                <div class="ttr-post-info">
                                                    <div class="ttr-post-header">
                                                        <h6 class="post-title"><a href="#">Introduction EduChamp</a></h6>
                                                    </div>
                                                    <div class="ttr-post-meta">
                                                        <ul>
                                                            <li class="price">
                                                                <del>$190</del>
                                                                <h5>$120</h5>
                                                            </li>
                                                            <li class="review">03 Review</li>
                                                        </ul>
                                                    </div>
                                                </div>
                                            </div>
                                            <div class="widget-post clearfix">
                                                <div class="ttr-post-media"> <img src="${pageContext.request.contextPath}/assets/images/blog/recent-blog/pic3.jpg" width="200" height="160" alt=""> </div>
                                                <div class="ttr-post-info">
                                                    <div class="ttr-post-header">
                                                        <h6 class="post-title"><a href="#">English For Tommorow</a></h6>
                                                    </div>
                                                    <div class="ttr-post-meta">
                                                        <ul>
                                                            <li class="price">
                                                                <h5 class="free">Free</h5>
                                                            </li>
                                                            <li class="review">07 Review</li>
                                                        </ul>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>


                                <!-- List_of_Room START -->
                                <div class="col-lg-9 col-md-8 col-sm-12">
                                    <div class="row">

                                        <%
                                            // Tạo danh sách người dùng mẫu
                                            List<RoomType> roomTypes = (List<RoomType>) request.getAttribute("roomTypes");
                                            int currentPage = (Integer) request.getAttribute("currentPage");
                                            int recordsPerPage = (Integer) request.getAttribute("recordsPerPage");
                                            int totalPages = (Integer)request.getAttribute("totalPages");
                                            int totalRecords = roomTypes.size();

                                            int startIndex = (currentPage - 1) * recordsPerPage;
                                            int endIndex = Math.min(startIndex + recordsPerPage, totalRecords);
                                            
                                            if (roomTypes != null) {
                                                for (int i = startIndex; i < endIndex; i++) {
                                                    RoomType type = roomTypes.get(i);
                                                        
                                                    String description = type.getDescription();
                                                    String features[] = description.split(",");
                                                    String secondFeature = "";
                                                    if (features.length > 1) {
                                                        secondFeature = features[1].trim();
                                                    }
                                        %>

                                        <div class="col-md-6 col-lg-4 col-sm-6 m-b30">
                                            <div class="cours-bx">
                                                <div class="action-box">
                                                    <img src="${pageContext.request.contextPath}/assets/images/uploads/<%= type.getImageUrl() %>" alt="Room1">
                                                    <a href="RoomDetailServlet?id=<%= type.getId() %>" class="btn">Read More</a>
                                                </div>
                                                <div class="info-bx text-center">
                                                    <h5><a href="RoomDetailServlet?id=<%= type.getId() %>"><%= type.getName() %></a></h5>
                                                    <span><%= secondFeature %></span>
                                                </div>
                                                <div class="cours-more-info">
                                                    <div class="review">
                                                        <span>3 Review</span>
                                                        <ul class="cours-star">
                                                            <li class="active"><i class="fa fa-star"></i></li>
                                                            <li class="active"><i class="fa fa-star"></i></li>
                                                            <li class="active"><i class="fa fa-star"></i></li>
                                                            <li><i class="fa fa-star"></i></li>
                                                            <li><i class="fa fa-star"></i></li>
                                                        </ul>
                                                    </div>
                                                    <div class="price">
                                                        <del>$190</del>
                                                        <h5>$<%= type.getBasePrice() %></h5>
                                                    </div>
                                                </div>

                                            </div>
                                            <div style="text-align: center; margin-top: 10px;">
                                                <a href="RoomListServlet?action=delete&id=<%= type.getId() %>&status=inactive" class="btn">Delete</a>
                                            </div>
                                        </div>
                                        <%
                                                }
                                            } else {
                                        %>
                                        <p>No data.</p>
                                        <%
                                            }
                                        %>

                                        <!--Phân trang START-->
                                        <div class="col-lg-12 m-b20">
                                            <div class="pagination-bx rounded-sm gray clearfix">
                                                <ul class="pagination">
                                                    <% if(currentPage == 1){ %>
                                                    <li class="previous"><a href="#"><i class="ti-arrow-left"></i> Prev</a></li>
                                                        <% } else { %>
                                                    <li class="previous"><a href="RoomListServlet?page=<%= currentPage - 1 %>"><i class="ti-arrow-left"></i> Prev</a></li>
                                                        <% } %>

                                                    <% for(int i = 1; i <= (Integer)request.getAttribute("totalPages"); i++) { 
                                                        if(i == currentPage) { %>
                                                    <li class="active"><a href="#"><%= i %></a></li>
                                                        <% } else { %>
                                                    <li><a href="RoomListServlet?page=<%= i %>"><%= i %></a></li>
                                                        <% } 
                                                    } %>

                                                    <% if(currentPage == totalPages){ %>
                                                    <li class="next"><a href="#">Next <i class="ti-arrow-right"></i></a></li>
                                                            <% } else { %>
                                                    <li class="next"><a href="RoomListServlet?page=<%= currentPage + 1 %>">Next <i class="ti-arrow-right"></i></a></li>
                                                            <% } %>
                                                </ul>
                                            </div>
                                        </div>
                                        <!--Phân trang END-->

                                    </div>
                                </div>
                                <!-- List_of_Room END -->

                            </div>
                        </div>
                    </div>
                </div>
                <!-- contact area END -->

            </div>
            <!-- Content END-->
            <!-- Footer ==== -->
            <jsp:include page="footer.jsp" />

            <!-- Footer END ==== -->
            <button class="back-to-top fa fa-chevron-up" ></button>
        </div>

        <script>
            function toggleDropdown(el) {
                const li = el.closest("li");
                li.classList.toggle("open");

                // Đóng các dropdown khác nếu có
                document.querySelectorAll(".navbar-nav > li").forEach(item => {
                    if (item !== li)
                        item.classList.remove("open");
                });
            }

            function selectFilter(inputId, value) {
                document.getElementById(inputId).value = value;
                document.getElementById("filterForm").submit();
            }

            // Đóng dropdown nếu click ra ngoài
            document.addEventListener('click', function (e) {
                if (!e.target.closest('.navbar-nav')) {
                    document.querySelectorAll('.navbar-nav > li').forEach(li => li.classList.remove('open'));
                }
            });
        </script>


        <!-- External JavaScripts -->
        <script src="${pageContext.request.contextPath}/assets/js/jquery.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/vendors/bootstrap/js/popper.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/vendors/bootstrap/js/bootstrap.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/vendors/bootstrap-select/bootstrap-select.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/vendors/bootstrap-touchspin/jquery.bootstrap-touchspin.js"></script>
        <script src="${pageContext.request.contextPath}/assets/vendors/magnific-popup/magnific-popup.js"></script>
        <script src="${pageContext.request.contextPath}/assets/vendors/counter/waypoints-min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/vendors/counter/counterup.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/vendors/imagesloaded/imagesloaded.js"></script>
        <script src="${pageContext.request.contextPath}/assets/vendors/masonry/masonry.js"></script>
        <script src="${pageContext.request.contextPath}/assets/vendors/masonry/filter.js"></script>
        <script src="${pageContext.request.contextPath}/assets/vendors/owl-carousel/owl.carousel.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/functions.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/contact.js"></script>
        <script src='${pageContext.request.contextPath}/assets/vendors/switcher/switcher.js'></script>
    </body>
</html>
