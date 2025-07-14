<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="model.RoomType" %>
<%@ page import="java.util.List" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <title>Luxury Hotel | Our Rooms</title>

        <!-- FAVICONS ICON -->
        <link rel="icon" href="${pageContext.request.contextPath}/assets/images/favicon.ico" type="image/x-icon" />
        <link rel="shortcut icon" type="image/x-icon" href="${pageContext.request.contextPath}/assets/images/favicon.png" />

        <!-- All PLUGINS CSS -->
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/css/assets.css">
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/css/typography.css">
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/css/shortcodes/shortcodes.css">
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/css/style.css">
        <link class="skin" rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/assets/css/color/color-1.css">

        <style>
            .cours-bx {
                transition: transform 0.3s ease, box-shadow 0.3s ease;
            }

            .cours-bx:hover {
                transform: translateY(-5px);
                box-shadow: 0 10px 25px rgba(0,0,0,0.15);
            }

            .price-display {
                font-size: 18px;
                font-weight: bold;
                color: #007bff;
            }

            .capacity-badge {
                background: #f8f9fa;
                border: 1px solid #dee2e6;
                padding: 4px 8px;
                border-radius: 4px;
                font-size: 12px;
                color: #495057;
            }

            .search-section {
                background: #f8f9fa;
                padding: 20px;
                border-radius: 8px;
                margin-bottom: 20px;
            }

            .filter-section {
                background: white;
                padding: 15px;
                border-radius: 8px;
                box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            }

            .no-results {
                text-align: center;
                padding: 60px 20px;
                color: #6c757d;
            }

            .no-results i {
                font-size: 4rem;
                margin-bottom: 20px;
                color: #dee2e6;
            }

            @media (max-width: 768px) {
                .sidebar-filters {
                    margin-bottom: 30px;
                }
            }
            /* 1) container relative + overflow để cắt nội dung ngoài khung */
            .cours-bx .action-box {
                position: relative;
                overflow: hidden;
            }

            /* 2) Hai nút ở trạng thái off-screen (vẫn giữ không gian để animation hoạt động) */
            .cours-bx .action-box a.btn-add,
            .cours-bx .action-box a.btn-detail {
                position: absolute;
                top: 50%;
                width: 45%;
                opacity: 0;
                transition: left 0.3s ease, right 0.3s ease, opacity 0.3s ease;
                z-index: 100;
            }

            /* Đẩy hoàn toàn ra ngoài khung */
            .cours-bx .action-box a.btn-add {
                left: -100%;
                transform: translateY(-50%);
            }
            .cours-bx .action-box a.btn-detail {
                right: -100%;
                transform: translateY(-50%);
            }

            /* 3) Khi hover: kéo vào đúng vị trí và fade in */
            .cours-bx:hover .action-box a.btn-add {
                left: 5%;
                opacity: 1;
            }
            .cours-bx:hover .action-box a.btn-detail {
                right: 5%;
                opacity: 1;
            }


        </style>
    </head>

    <body id="bg">
        <div class="page-wraper">
            <div id="loading-icon-bx"></div>

            <!-- Header -->
            <jsp:include page="header.jsp" />

            <!-- Content -->
            <div class="page-content bg-white">
                <!-- Banner -->
                <div class="page-banner ovbl-dark" style="background-image:url('${pageContext.request.contextPath}/assets/images/banner/banner2.jpg');">
                    <div class="container">
                        <div class="page-banner-entry">
                            <h1 class="text-white">Our Room Collection</h1>
                            <p class="text-white">Discover comfort and luxury in every room</p>
                        </div>
                    </div>
                </div>

                <!-- Breadcrumb -->
                <div class="breadcrumb-row">
                    <div class="container">
                        <ul class="list-inline">
                            <li><a href="${pageContext.request.contextPath}/">Home</a></li>
                            <li>Rooms</li>
                        </ul>
                    </div>
                </div>

                <div class="content-block">
                    <div class="section-area section-sp1">
                        <div class="container">
                            <c:if test="${param.added eq '1'}">
                                <div class="alert alert-success text-center mb-3">Add to cart room successful!</div>
                            </c:if>
                            <div class="row">
                                <!-- Sidebar -->
                                <div class="col-lg-3 col-md-4 col-sm-12 m-b30 sidebar-filters">

                                    <!-- Search -->
                                    <div class="search-section">
                                        <h5 class="widget-title">Search Rooms</h5>
                                        <form action="SearchAvailableRoomsServlet" method="get" id="roomListSearchForm">
                                            <!-- Preserve selected filters when performing a new search -->
                                            <input type="hidden" name="price" value="${selectedPrice}">
                                            <input type="hidden" name="capacity" value="${selectedCapacity}">
                                            <div class="form-group">
                                                <label>Check-in</label>
                                                <input type="date" name="checkIn" class="form-control"
                                                       value="${searchCheckIn}"
                                                       min="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>"
                                                       required>
                                            </div>
                                            <div class="form-group">
                                                <label>Check-out</label>
                                                <input type="date" name="checkOut" class="form-control"
                                                       value="${searchCheckOut}"
                                                       min="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date(System.currentTimeMillis() + 24*60*60*1000)) %>"
                                                       required>
                                            </div>
                                            <div class="form-group">
                                                <label>Room Type</label>
                                                <select name="roomTypeId" class="form-control">
                                                    <option value="">All Room Types</option>
                                                    <c:forEach var="roomType" items="${searchRoomTypes}">
                                                        <option value="${roomType.id}"
                                                                <c:if test="${searchRoomTypeId eq roomType.id}">selected</c:if>>
                                                            ${roomType.name}
                                                        </option>
                                                    </c:forEach>
                                                </select>
                                            </div>
                                            <button type="submit" class="btn btn-primary btn-block">Search</button>
                                        </form>
                                    </div>

                                    <!-- Filters -->
                                    <div class="filter-section">
                                        <h5 class="widget-title">Filter by</h5>
                                        <form action="SearchAvailableRoomsServlet" method="get">
                                            <!-- Keep current search parameters when filtering -->
                                            <input type="hidden" name="checkIn" value="${searchCheckIn}">
                                            <input type="hidden" name="checkOut" value="${searchCheckOut}">
                                            <input type="hidden" name="roomTypeId" value="${searchRoomTypeId}">
                                            <div class="form-group">
                                                <label>Price Range</label>
                                                <select name="price" class="form-control" onchange="this.form.submit()">
                                                    <option value="">All Prices</option>
                                                    <option value="1" ${selectedPrice == '1' ? 'selected' : ''}>Under 500,000₫</option>
                                                    <option value="2" ${selectedPrice == '2' ? 'selected' : ''}>500,000₫ - 1,000,000₫</option>
                                                    <option value="3" ${selectedPrice == '3' ? 'selected' : ''}>Over 1,000,000₫</option>
                                                </select>
                                            </div>

                                            <div class="form-group">
                                                <label>Capacity</label>
                                                <select name="capacity" class="form-control" onchange="this.form.submit()">
                                                    <option value="">All Capacities</option>
                                                    <option value="1" ${selectedCapacity == '1' ? 'selected' : ''}>1 Guest</option>
                                                    <option value="2" ${selectedCapacity == '2' ? 'selected' : ''}>2 Guests</option>
                                                    <option value="3" ${selectedCapacity == '3' ? 'selected' : ''}>3 Guests</option>
                                                    <option value="4" ${selectedCapacity == '4' ? 'selected' : ''}>4+ Guests</option>
                                                </select>
                                            </div>

                                            <c:if test="${not empty selectedPrice || not empty selectedCapacity}">
                                                <a href="SearchAvailableRoomsServlet?checkIn=${searchCheckIn}&checkOut=${searchCheckOut}&roomTypeId=${searchRoomTypeId}" class="btn btn-secondary btn-block">
                                                    <i class="fa fa-times"></i> Clear Filters
                                                </a>
                                            </c:if>
                                        </form>
                                    </div>

                                    <!-- Featured Room -->
                                    <div class="widget mt-4">
                                        <h5 class="widget-title">Featured Room</h5>
                                        <div class="widget-post-bx">
                                            <div class="widget-post clearfix">
                                                <div class="ttr-post-media"> 
                                                    <img src="${pageContext.request.contextPath}/assets/images/uploads/presidential_suite.jpg" 
                                                         width="200" height="143" alt="Featured Room"> 
                                                </div>
                                                <div class="ttr-post-info">
                                                    <div class="ttr-post-header">
                                                        <h6 class="post-title"><a href="/RoomDetailServlet?id=1002">Presidential Suite</a></h6>
                                                    </div>
                                                    <div class="ttr-post-meta">
                                                        <ul>
                                                            5/5<i class="fa fa-star" style="color: #ffc107"></i>
                                                            <li class="price">                                       
                                                                <h5 class="price-display" >3,000,000₫/night</h5>

                                                            </li>

                                                        </ul>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Room List -->
                                <div class="col-lg-9 col-md-8 col-sm-12">

                                    <!-- Results Summary -->
                                    <c:if test="${not empty roomTypes}">
                                        <div class="d-flex justify-content-between align-items-center mb-4">
                                            <h4 class="mb-0">Available Rooms</h4>
                                            <span class="text-muted">${totalRecords} room types found</span>
                                        </div>
                                    </c:if>

                                    <div class="row">
                                        <%
                                            List<RoomType> roomTypes = (List<RoomType>) request.getAttribute("roomTypes");
                                            Integer currentPage = (Integer) request.getAttribute("currentPage");
                                            Integer recordsPerPage = (Integer) request.getAttribute("recordsPerPage");
                                            Integer totalPages = (Integer) request.getAttribute("totalPages");
                                        
                                            if (roomTypes != null && !roomTypes.isEmpty()) {
                                                int totalRecords = roomTypes.size();
                                                int startIndex = (currentPage - 1) * recordsPerPage;
                                                int endIndex = Math.min(startIndex + recordsPerPage, totalRecords);
                                            
                                                for (RoomType type : roomTypes) {
                                                    String description = type.getDescription();
                                                    String[] features = description.split(",");
                                                    String bedType = features.length > 1 ? features[1].trim() : "Standard Bed";
                                        %>
                                        <div class="col-md-6 col-lg-4 col-sm-6 m-b30" style="margin-bottom: 30px;">
                                            <div class="cours-bx">
                                                <div class="action-box">
                                                    <img src="${pageContext.request.contextPath}/assets/images/uploads/<%= type.getImageUrl() %>" 
                                                         alt="<%= type.getName() %>" style="height: 200px; object-fit: cover;">
                                                    <c:choose>
                                                        <c:when test="${not empty searchCheckIn && not empty searchCheckOut}">
                                                            <% if (type.getAvailableRoomCount() > 0) { %>
                                                            <a href="CartServlet?action=add&roomTypeId=<%= type.getId() %>&roomTypeName=<%= java.net.URLEncoder.encode(type.getName(), "UTF-8") %>&price=<%= type.getBasePrice() %>&checkIn=${searchCheckIn}&checkOut=${searchCheckOut}" class="btn btn-primary">Add to Cart</a>
                                                            <% } else { %>
                                                            <span class="btn btn-secondary disabled">Sold Out</span>
                                                            <% } %>

                                                        </c:when>
                                                        <c:otherwise>
                                                            <a href="RoomDetailServlet?id=<%= type.getId() %>" class="btn">View Detail</a>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </div>
                                                <div class="info-bx text-center">
                                                    <c:choose>
                                                        <c:when test="${not empty searchCheckIn && not empty searchCheckOut}">
                                                            <h5><a href="RoomDetailServlet?id=<%= type.getId() %>&checkIn=${searchCheckIn}&checkOut=${searchCheckOut}"><%= type.getName() %></a></h5>
                                                            </c:when>
                                                            <c:otherwise>
                                                            <h5><a href="RoomDetailServlet?id=<%= type.getId() %>"><%= type.getName() %></a></h5>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    <span class="capacity-badge">
                                                        <i class="fa fa-users"></i> <%= type.getCapacity() %> guests
                                                    </span>
                                                    <span class="capacity-badge ml-2">
                                                        <i class="fa fa-bed"></i> <%= bedType %>
                                                    </span>
                                                    <div class="mt-2">
                                                        <small><%= type.getAvailabilityMessage() %></small>
                                                    </div>
                                                </div>
                                                <div class="cours-more-info">
                                                    <div class="review">
                                                        <span><%= String.format("%.1f", type.getAverageRating()) %>/5 </span>

                                                        <i class="fa fa-star" style="color: #ffc107"></i>

                                                        <span class="text-muted">(<%= type.getReviewCount() %>)</span>



                                                    </div>
                                                    <div class="price">
                                                        <span class="price-display">
                                                            <fmt:formatNumber value="<%= type.getBasePrice() %>" pattern="#,##0" />₫
                                                        </span>
                                                        <small class="text-muted">/night</small>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <%
                                                }
                                            } else {
                                        %>
                                        <div class="col-12">
                                            <div class="no-results">
                                                <i class="fa fa-bed"></i>
                                                <h4>No rooms found</h4>
                                                <p>Try adjusting your search criteria or browse all available rooms.</p>
                                                <a href="SearchAvailableRoomsServlet" class="btn btn-primary">View All Rooms</a>
                                            </div>
                                        </div>
                                        <%
                                            }
                                        %>

                                        <!-- Pagination -->
                                        <c:if test="${totalPages > 1}">
                                            <div class="col-lg-12 m-b20">
                                                <div class="pagination-bx rounded-sm gray clearfix">
                                                    <ul class="pagination">
                                                        <!-- Previous -->
                                                        <c:choose>
                                                            <c:when test="${currentPage == 1}">
                                                                <li class="previous disabled">
                                                                    <span><i class="ti-arrow-left"></i> Previous</span>
                                                                </li>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <li class="previous">
                                                                    <a href="?page=${currentPage - 1}&keyword=${keyword}&price=${selectedPrice}&capacity=${selectedCapacity}&checkIn=${searchCheckIn}&checkOut=${searchCheckOut}">                                                                        <i class="ti-arrow-left"></i> Previous
                                                                    </a>
                                                                </li>
                                                            </c:otherwise>
                                                        </c:choose>

                                                        <!-- Page numbers -->
                                                        <c:forEach begin="1" end="${totalPages}" var="i">
                                                            <c:choose>
                                                                <c:when test="${i == currentPage}">
                                                                    <li class="active"><span>${i}</span></li>
                                                                        </c:when>
                                                                        <c:otherwise>
                                                                    <li>
                                                                        <a href="?page=${i}&keyword=${keyword}&price=${selectedPrice}&capacity=${selectedCapacity}&checkIn=${searchCheckIn}&checkOut=${searchCheckOut}">
                                                                            ${i}
                                                                        </a>
                                                                    </li>
                                                                </c:otherwise>
                                                            </c:choose>
                                                        </c:forEach>

                                                        <!-- Next -->
                                                        <c:choose>
                                                            <c:when test="${currentPage == totalPages}">
                                                                <li class="next disabled">
                                                                    <span>Next <i class="ti-arrow-right"></i></span>
                                                                </li>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <li class="next">
                                                                    <a href="?page=${currentPage + 1}&keyword=${keyword}&price=${selectedPrice}&capacity=${selectedCapacity}&checkIn=${searchCheckIn}&checkOut=${searchCheckOut}">
                                                                        Next <i class="ti-arrow-right"></i>
                                                                    </a>
                                                                </li>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </ul>
                                                </div>
                                            </div>
                                        </c:if>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Footer -->
            <jsp:include page="footer.jsp" />
            <button class="back-to-top fa fa-chevron-up"></button>
        </div>

        <!-- Scripts -->
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

        <script>
                                                    // Auto-submit form when filter changes
                                                    $(document).ready(function () {
                                                        $('.filter-form select').on('change', function () {
                                                            $(this).closest('form').submit();
                                                        });

                                                        // Add loading animation
                                                        $('form').on('submit', function () {
                                                            $('#loading-icon-bx').show();
                                                        });
                                                    });
        </script>
    </body>
</html>