<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!-- L?y URI hi?n t?i -->
<c:set var="currentUrl" value="${pageContext.request.requestURI}" />
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">

<style>
    .user-info {
        display: inline-flex;
        align-items: center;
        margin-right: 10px;
    }
    .user-avatar {
        width: 25px;
        height: 25px;
        border-radius: 50%;
        margin-right: 8px;
        background-color: #fff;
        display: inline-flex;
        align-items: center;
        justify-content: center;
        font-weight: bold;
        color: #333;
    }
    .dropdown-menu {
        margin-top: 10px;
    }
    .dropdown-toggle::after {
        margin-left: 5px;
    }
    .user-dropdown {
        position: relative;
        display: inline-block;
    }
</style>

<header class="header rs-nav header-transparent">

    <!-- Top bar -->
    <div class="top-bar">
        <div class="container d-flex justify-content-between">
            <ul class="list-inline mb-0">
                <li class="list-inline-item">
                    <a href="<c:url value='/faq-1.html'/>"><i class="fa fa-question-circle"></i>Ask a Question</a>
                </li>
                <li class="list-inline-item">
                    <a href="https://mail.google.com/mail/?view=cm&fs=1&to=luxuryhotel999@gmail.com&su=Feedback%20from%20Website&body=Hello%20Luxury%20Hotel," target="_blank" rel="noopener">
                        <i class="fa fa-envelope-o"></i>
                        luxuryhotel999@gmail.com
                    </a>
                </li>
            </ul>
            <ul class="list-inline mb-0">
                <c:choose>
                    <c:when test="${not empty sessionScope.user}">
                        <!-- User is logged in -->
                        <li class="list-inline-item">
                            <div class="user-dropdown dropdown">
                                <a href="#" class="dropdown-toggle" data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                                    <span class="user-info">
                                        <span class="user-avatar">
                                            ${fn:substring(sessionScope.user.fullName, 0, 1)}
                                        </span>
                                        Welcome, ${sessionScope.user.fullName}
                                    </span>
                                </a>
                                <div class="dropdown-menu dropdown-menu-right">
                                    <!-- Show different options based on role -->
                                    <c:choose>
                                        <c:when test="${sessionScope.user.role eq 'ADMIN'}">
                                            <a class="dropdown-item" href="${pageContext.request.contextPath}/admin/dashboard">
                                                <i class="fa fa-tachometer-alt"></i> Dashboard
                                            </a>
                                            <a class="dropdown-item" href="${pageContext.request.contextPath}/admin/customers">
                                                <i class="fa fa-users"></i> Manage Customers
                                            </a>
                                                <a class="dropdown-item" href="${pageContext.request.contextPath}/admin/housekeeping">
                                                <i class="fa fa-users"></i> Manage Housekeeping
                                            </a>
                                                
                                            <div class="dropdown-divider"></div>
                                        </c:when>
                                        <c:when test="${sessionScope.user.role eq 'RECEPTIONIST'}">
                                            <a class="dropdown-item" href="${pageContext.request.contextPath}/receptionist/bookings">
                                                <i class="fa fa-calendar-check"></i> Manage Bookings
                                            </a>
                                            <a class="dropdown-item" href="${pageContext.request.contextPath}/receptionist/checkin">
                                                <i class="fa fa-sign-in-alt"></i> Check-in/Check-out
                                            </a>
                                            <div class="dropdown-divider"></div>
                                        </c:when>
                                        <c:when test="${sessionScope.user.role eq 'HOUSEKEEPER'}">
                                            <a class="dropdown-item" href="${pageContext.request.contextPath}/housekeeping">
                                                <i class="fa fa-tasks"></i> My Tasks
                                            </a>
                                            <a class="dropdown-item" href="${pageContext.request.contextPath}/housekeeping/rooms">
                                                <i class="fa fa-bed"></i> Room Status
                                            </a>
                                            <div class="dropdown-divider"></div>
                                        </c:when>
                                        <c:when test="${sessionScope.user.role eq 'GUEST'}">
                                            <a class="dropdown-item" href="${pageContext.request.contextPath}/customer/profile">
                                                <i class="fa fa-user"></i> My Profile
                                            </a>
                                            <a class="dropdown-item" href="${pageContext.request.contextPath}/customer/bookings">
                                                <i class="fa fa-calendar"></i> My Bookings
                                            </a>
                                            <a class="dropdown-item" href="${pageContext.request.contextPath}/customer/history">
                                                <i class="fa fa-history"></i> Booking History
                                            </a>
                                            <div class="dropdown-divider"></div>
                                        </c:when>
                                    </c:choose>
                                    
                                    <!-- Common items for all users -->
                                    <a class="dropdown-item" href="${pageContext.request.contextPath}/reset-password">
                                        <i class="fa fa-key"></i> Change Password
                                    </a>
                                    <a class="dropdown-item" href="${pageContext.request.contextPath}/LogoutServlet">
                                        <i class="fa fa-sign-out-alt"></i> Logout
                                    </a>
                                </div>
                            </div>
                        </li>
                    </c:when>
                    <c:otherwise>
                        <!-- User is not logged in -->
                        <li class="list-inline-item">
                            <svg xmlns="http://www.w3.org/2000/svg"
                                 fill="none"
                                 viewBox="0 0 24 24"
                                 stroke-width="1.5"
                                 stroke="currentColor"
                                 class="size-6"
                                 style="width:1.3em; height:1.3em; vertical-align:middle;">
                                <path stroke-linecap="round" stroke-linejoin="round"
                                      d="M15.75 6a3.75 3.75 0 1 1-7.5 0 3.75 3.75 0 0 1 7.5 0ZM4.501 20.118a7.5 7.5 0 0 1 14.998 0A17.933 17.933 0 0 1 12 21.75c-2.676 0-5.216-.584-7.499-1.632Z"/>
                            </svg>
                            <a href="<c:url value='/jsp/login.jsp'/>">Login</a>
                        </li>
                        <li class="list-inline-item">
                            <a href="<c:url value='/jsp/Register.jsp'/>">Register</a>
                        </li>
                    </c:otherwise>
                </c:choose>
            </ul>
        </div>
    </div>

    <!-- Main nav -->
    <div class="sticky-header navbar-expand-lg">
        <div class="menu-bar container clearfix">
            <a class="menu-logo" href="<c:url value='/index.jsp'/>">
                <img src="${pageContext.request.contextPath}/assets/images/logo-white.png" alt="Luxury Hotel Logo"/>
            </a>
            <button class="navbar-toggler collapsed menuicon" data-toggle="collapse" data-target="#menuDropdown" aria-label="Toggle navigation">
                <span></span><span></span><span></span>
            </button>

            <!-- Secondary Menu -->
            <div class="secondary-menu">
                <ul class="list-inline mb-0">
                    <li class="list-inline-item"><a href="#" class="btn-link"><i class="fab fa-facebook-f"></i></a></li>
                    <li class="list-inline-item"><a href="#" class="btn-link"><i class="fab fa-google-plus-g"></i></a></li>
                    <li class="list-inline-item"><a href="#" class="btn-link"><i class="fab fa-linkedin-in"></i></a></li>
                </ul>
            </div>
            
            <!-- Search Bar -->
            <div class="nav-search-bar">
                <form action="#"><input type="text" placeholder="Type to search"/><span><i class="ti-search"></i></span></form>
                <span id="search-remove"><i class="ti-close"></i></span>
            </div>

            <!-- Menu Links -->
            <nav class="menu-links collapse navbar-collapse" id="menuDropdown">
                <ul class="nav navbar-nav">
                    <li class="nav-item ${fn:endsWith(currentUrl,'/index.jsp') ? 'active' : ''}">
                        <a class="nav-link" href="${pageContext.request.contextPath}/index.jsp">HOME</a>
                    </li>
                    <li class="nav-item ${fn:endsWith(currentUrl,'/About.jsp') ? 'active' : ''}">
                        <a class="nav-link" href="${pageContext.request.contextPath}/jsp/About.jsp">ABOUT</a>
                    </li>
                    <li class="nav-item ${fn:endsWith(currentUrl,'/roomList.jsp') ? 'active' : ''}">
                        <a class="nav-link" href="${pageContext.request.contextPath}/RoomListServlet">LIST ROOM</a>
                    </li>
                    <li class="nav-item ${fn:endsWith(currentUrl,'/contact.jsp') ? 'active' : ''}">
                        <a class="nav-link" href="${pageContext.request.contextPath}/jsp/contact.jsp">CONTACT</a>
                    </li>
                    <li class="nav-item ${fn:endsWith(currentUrl,'/blog.jsp') ? 'active' : ''}">
                        <a class="nav-link" href="${pageContext.request.contextPath}/BlogListServlet">BLOG</a>
                    </li>
                    <li class="nav-item ${fn:endsWith(currentUrl,'/HouseKeeping.jsp') ? 'active' : ''}">
                        <a class="nav-link" href="${pageContext.request.contextPath}/admin/housekeeping?action=list">Housekeeping</a>
                    </li>

                    
                    <!-- Show menu items based on user role -->
                    <c:if test="${not empty sessionScope.user}">
                        <c:choose>
                            <c:when test="${sessionScope.user.role eq 'ADMIN'}">
                                <li class="nav-item ${fn:contains(currentUrl,'/admin/') ? 'active' : ''}">
                                    <a class="nav-link" href="${pageContext.request.contextPath}/admin/customers">
                                        MANAGE CUSTOMERS
                                    </a>
                                        
                                </li>
                                
                                  <li class="nav-item ${fn:endsWith(currentUrl,'/HouseKeeping.jsp') ? 'active' : ''}">
                                    <a class="nav-link" href="${pageContext.request.contextPath}/admin/housekeeping">
                                       Manager HOUSEKEEPING
                                    </a>
                                </li>
                            </c:when>
                                
                            <c:when test="${sessionScope.user.role eq 'HOUSEKEEPER'}">
                                <li class="nav-item ${fn:endsWith(currentUrl,'/HouseKeeping.jsp') ? 'active' : ''}">
                                    <a class="nav-link" href="${pageContext.request.contextPath}/admin/housekeeping?action=list">
                                        HOUSEKEEPING
                                    </a>
                                </li>
                            </c:when>
                            <c:when test="${sessionScope.user.role eq 'RECEPTIONIST'}">
                                <li class="nav-item ${fn:contains(currentUrl,'/receptionist/') ? 'active' : ''}">
                                    <a class="nav-link" href="${pageContext.request.contextPath}/receptionist/bookings">
                                        BOOKINGS
                                    </a>
                                </li>
                            </c:when>
                        </c:choose>
                    </c:if>
                </ul>
            </nav>
        </div>
    </div>
</header>

<!-- Add necessary JavaScript for dropdown -->
<script>
    $(document).ready(function() {
        // Initialize dropdown
        $('.dropdown-toggle').dropdown();
    });
</script>