<%-- 
    Document   : admin-roomList
    Created on : 1 thg 6, 2025, 17:12:07
    Author     : ASUS
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="model.RoomType" %>
<%@ page import="model.Room" %>
<%@ page import="dal.RoomTypeDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Arrays" %>
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
        <link rel="icon" href="../error-404.html" type="image/x-icon" />
        <link rel="shortcut icon" type="image/x-icon" href="${pageContext.request.contextPath}/admin/assets/images/favicon.png" />

        <!-- PAGE TITLE HERE ============================================= -->
        <title>EduChamp : Education HTML Template </title>

        <!-- MOBILE SPECIFIC ============================================= -->
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <!--[if lt IE 9]>
        <script src="${pageContext.request.contextPath}/admin/assets/js/html5shiv.min.js"></script>
        <script src="${pageContext.request.contextPath}/admin/assets/js/respond.min.js"></script>
        <![endif]-->

        <!-- All PLUGINS CSS ============================================= -->
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/admin/assets/css/assets.css">
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/admin/assets/vendors/calendar/fullcalendar.css">

        <!-- TYPOGRAPHY ============================================= -->
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/admin/assets/css/typography.css">

        <!-- SHORTCODES ============================================= -->
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/admin/assets/css/shortcodes/shortcodes.css">

        <!-- STYLESHEETS ============================================= -->
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/admin/assets/css/style.css">
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/admin/assets/css/dashboard.css">
        <link class="skin" rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/admin/assets/css/color/color-1.css">
    </head>
    <body class="ttr-opened-sidebar ttr-pinned-sidebar">

        <jsp:include page="admin-header.jsp" />

        

        <!--Main container start -->
        <main class="ttr-wrapper">
            <div class="container-fluid">
                <div class="db-breadcrumb">
                    <h4 class="breadcrumb-title">Courses</h4>
                    <ul class="db-breadcrumb-list">
                        <li><a href="#"><i class="fa fa-home"></i>Home</a></li>
                        <li>Courses</li>
                    </ul>
                </div>	
                <div class="row">
                    <div style="display: flex; justify-content: space-between; align-items: center; width: 100%;">
                        <a href="jsp/create-roomtype.jsp" class="btn button-sm radius-xl" style="height: 40px; line-height: 40px; font-size: 15px; padding: 0 20px;">
                            Create New Type
                        </a>
                        <form action="RoomListServlet" method="get" style="display: flex; gap: 10px; align-items: center;">
                            <select name="price" class="form-select" style="height: 40px;">
                                <option value="">-- Filter by Price --</option>
                                <option value="1" ${selectedCapacity == '1' ? 'selected' : ''}>Under 500k</option>
                                <option value="2" ${selectedCapacity == '1' ? 'selected' : ''}>500k - 1M</option>
                                <option value="3" ${selectedCapacity == '1' ? 'selected' : ''}>Over 1M</option>
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
                        <div class="widget courses-search-bx placeani">
                            <div class="form-group">
                                <form action="RoomListServlet" method="get">
                                    <div class="input-group">
                                        <label style="margin: 0;">Search Rooms</label>
                                        <input name="keyword" type="text" value="${keyword}" class="form-control" style="height: 36px; padding: 5px 10px; font-size: 14px;">
                                        <button type="submit" class="btn" style="height: 36px; padding: 0 15px;">Search</button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>

                    <!-- Your Profile Views Chart -->
                    <div class="col-lg-12 m-b30">
                        <div class="widget-box">
                            <div class="wc-title">
                                <h4>Your Courses</h4>
                            </div>
                            <div class="widget-inner">

                                <%
                                    // Tạo danh sách người dùng mẫu
                                    List<RoomType> roomTypes = (List<RoomType>) request.getAttribute("roomTypes");
                                    RoomTypeDAO dao = new RoomTypeDAO();
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
                                                    String bed = "";
                                                    String shortDescrip = "";
                                                    if (features.length > 1) {
                                                        bed = features[0].trim();
                                                        shortDescrip = features[1].trim();
                                                    }
                                %>
                                <div class="card-courses-list admin-courses">
                                    <div class="card-courses-media">
                                        <img src="${pageContext.request.contextPath}<%= type.getImageUrl() %>" alt="RoomType"/>
                                    </div>
                                    <div class="card-courses-full-dec">
                                        <div class="card-courses-title">
                                            <h4><a href="RoomDetailServlet?id=<%= type.getId() %>"><%= type.getName() %></a></h4>
                                        </div>
                                        <div class="card-courses-list-bx">
                                            <ul class="card-courses-view">
                                                <li class="card-courses-user">

                                                    <div class="card-courses-user-info">
                                                        <h5>ID</h5>
                                                        <h4><%= type.getId() %></h4>
                                                    </div>
                                                </li>
                                                <li class="card-courses-categories">
                                                    <h5>Capacity</h5>
                                                    <h4><%= type.getCapacity() %></h4>
                                                </li>
                                                <li class="card-courses-review">
                                                    <h5>3 Review</h5>
                                                    <ul class="cours-star">
                                                        <li class="active"><i class="fa fa-star"></i></li>
                                                        <li class="active"><i class="fa fa-star"></i></li>
                                                        <li class="active"><i class="fa fa-star"></i></li>
                                                        <li><i class="fa fa-star"></i></li>
                                                        <li><i class="fa fa-star"></i></li>
                                                    </ul>
                                                </li>
                                                <li class="card-courses-stats">
                                                    <%
                                                        String color = "red";
                                                        if ("active".equals(type.getStatus())) {
                                                            color = "white";
                                                        }
                                                    %>
                                                    <a class="btn button-sm green radius-xl" style="color: <%= color %>;">
                                                        <%= type.getStatus() %>
                                                    </a>
                                                </li>
                                                <li class="card-courses-price">
                                                    <del>$190</del>
                                                    <h5 class="text-primary">$<%= type.getBasePrice() %></h5>
                                                </li>
                                            </ul>
                                        </div>
                                        <div class="row card-courses-dec">
                                            <div class="col-md-12">
                                                <h6 class="m-b10">Room Type Description</h6>
                                                <p>Short Description: <%= shortDescrip %>
                                                    <br> Bed: <%= bed %>
                                                    <br> Amenities:
                                                    <%
                                                        for(int j = 2; j < features.length; j++){
                                                    %>
                                                    <span style="display:inline-block; width:10px;"></span><%= j-1 %>.<%= features[j] %>
                                                    <%
                                                        }
                                                    %>
                                                    <br> Create At: <%= type.getCreatedAt() %>
                                                    <br> Update At: <%= type.getUpdatedAt() %>
                                                </p>
                                                <p></p>
                                                <p></p>
                                                <h6 class="m-b10">Room Description</h6>
                                                <p><%= type.getDescription() %></p>


                                                <h6 class="m-b10">Rooms</h6>
                                                <ul style="list-style-type: none; padding-left: 0;">
                                                    <%
                                                        List<Room> roomList = dao.getRoomsByType(type.getId());
                                                        for(int x = 0; x < roomList.size(); x++){ 
                                                    %>
                                                    <li style="border-bottom: 1px solid rgba(0, 0, 0, 0.1); padding: 8px 0;">
                                                        ID of Room: <%=  roomList.get(x).getId() %> - Room Number: <%=  roomList.get(x).getRoomNumber() %> - Room Status: <%=  roomList.get(x).getStatus() %>
                                                    </li>
                                                    <%
                                                        }
                                                    %>
                                                </ul>
                                            </div>
                                            <div class="col-md-12">
                                                <a href="#" class="btn green radius-xl outline">Approve</a>
                                                <button type="button" onclick="submitDelete(<%= type.getId() %>, 'inactive');" class="btn red outline radius-xl">Cancel</button>
                                            </div>
                                        </div>

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

                            </div>
                        </div>
                    </div>
                    <!-- Your Profile Views Chart END-->

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
        </main>
        <div class="ttr-overlay"></div>


        <form id="deleteForm" action="RoomListServlet" method="post" style="display:none;">
            <input type="hidden" name="action" value="delete">
            <input type="hidden" name="id" id="deleteId">
            <input type="hidden" name="status" id="deleteStatus">
        </form>
        <script>
            function submitDelete(id, status) {
                document.getElementById('deleteId').value = id;
                document.getElementById('deleteStatus').value = status;
                document.getElementById('deleteForm').submit();
            }
        </script>

        <!-- External JavaScripts -->
        <script src="${pageContext.request.contextPath}/admin/assets/js/jquery.min.js"></script>
        <script src="${pageContext.request.contextPath}/admin/assets/vendors/bootstrap/js/popper.min.js"></script>
        <script src="${pageContext.request.contextPath}/admin/assets/vendors/bootstrap/js/bootstrap.min.js"></script>
        <script src="${pageContext.request.contextPath}/admin/assets/vendors/bootstrap-select/bootstrap-select.min.js"></script>
        <script src="${pageContext.request.contextPath}/admin/assets/vendors/bootstrap-touchspin/jquery.bootstrap-touchspin.js"></script>
        <script src="${pageContext.request.contextPath}/admin/assets/vendors/magnific-popup/magnific-popup.js"></script>
        <script src="${pageContext.request.contextPath}/admin/assets/vendors/counter/waypoints-min.js"></script>
        <script src="${pageContext.request.contextPath}/admin/assets/vendors/counter/counterup.min.js"></script>
        <script src="${pageContext.request.contextPath}/admin/assets/vendors/imagesloaded/imagesloaded.js"></script>
        <script src="${pageContext.request.contextPath}/admin/assets/vendors/masonry/masonry.js"></script>
        <script src="${pageContext.request.contextPath}/admin/assets/vendors/masonry/filter.js"></script>
        <script src="${pageContext.request.contextPath}/admin/assets/vendors/owl-carousel/owl.carousel.js"></script>
        <script src='${pageContext.request.contextPath}/admin/assets/vendors/scroll/scrollbar.min.js'></script>
        <script src="${pageContext.request.contextPath}/admin/assets/js/functions.js"></script>
        <script src="${pageContext.request.contextPath}/admin/assets/vendors/chart/chart.min.js"></script>
        <script src="${pageContext.request.contextPath}/admin/assets/js/admin.js"></script>
        <script src='${pageContext.request.contextPath}/admin/assets/vendors/switcher/switcher.js'></script>
    </body>
</html>
