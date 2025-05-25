<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!-- L?y URI hi?n t?i -->
<c:set var="currentUrl" value="${pageContext.request.requestURI}" />
<!-- L?y URI hi?n t?i -->
<c:set var="currentUrl" value="${pageContext.request.requestURI}" />
<header class="header rs-nav header-transparent">
    <!-- Top bar -->
    <div class="top-bar">
        <div class="container d-flex justify-content-between">
            <ul class="list-inline mb-0">
                <li class="list-inline-item">
                    <a href="<c:url value='/faq-1.html'/>"><i class="fa fa-question-circle"></i>Ask a Question</a>
                </li>
                <li class="list-inline-item">
                    <a href="mailto:info@luxuryhotel.com"><i class="fa fa-envelope-o"></i>info@luxuryhotel.com</a>
                </li>
            </ul>
            <ul class="list-inline mb-0">
<!--                <li class="list-inline-item">
                    <select class="header-lang-bx">
                        <option data-icon="flag flag-uk">English UK</option>
                        <option data-icon="flag flag-us">English US</option>
                    </select>
                </li>-->
                <c:choose>
                    <c:when test="${not empty sessionScope.user}">
                        <li class="list-inline-item"><a href="<c:url value='/LogoutServlet'/>">Logout</a></li>
                        </c:when>
                        <c:otherwise>
                        <li class="list-inline-item"><a href="<c:url value='/jsp/Login.jsp'/>">Login</a></li>
                        <li class="list-inline-item"><a href="<c:url value='/jsp/Register.jsp'/>">Register</a></li>
                        </c:otherwise>
                    </c:choose>
            </ul>
        </div>
    </div>

    <!-- Main nav -->
    <div class="sticky-header navbar-expand-lg">
        <div class="menu-bar container clearfix">
            <a class="menu-logo" href="<c:url value='/index.jsp'/>"><img src="${pageContext.request.contextPath}/assets/images/logo-white.png" alt="Luxury Hotel Logo"/></a>
            <button class="navbar-toggler collapsed menuicon" data-toggle="collapse" data-target="#menuDropdown" aria-label="Toggle navigation">
                <span></span><span></span><span></span>
            </button>

            <!-- Secondary Menu -->
            <div class="secondary-menu">
                <ul class="list-inline mb-0">
                    <li class="list-inline-item"><a href="#" class="btn-link"><i class="fa fa-facebook"></i></a></li>
                    <li class="list-inline-item"><a href="#" class="btn-link"><i class="fa fa-google-plus"></i></a></li>
                    <li class="list-inline-item"><a href="#" class="btn-link"><i class="fa fa-linkedin"></i></a></li>
                    <li class="list-inline-item search-btn"><button id="quik-search-btn" class="btn-link"><i class="fa fa-search"></i></button></li>
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
                    <li class="nav-item ${fn:endsWith(currentUrl,'/ManagerCustomer.jsp') ? 'active' : ''}">
                        <a class="nav-link" href="${pageContext.request.contextPath}/jsp/ManagerCustomer.jsp">CONTACT</a>
                    </li>
                </ul>
            </nav>
        </div>
    </div>
</header>
