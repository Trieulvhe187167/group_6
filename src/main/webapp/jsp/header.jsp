<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
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
        <li class="list-inline-item">
          <select class="header-lang-bx">
            <option data-icon="flag flag-uk">English UK</option>
            <option data-icon="flag flag-us">English US</option>
          </select>
        </li>
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
          <li class="nav-item active"><a class="nav-link" href="<c:url value='/index.jsp'/>">Home</a></li>
          <li class="nav-item"><a class="nav-link" href="<c:url value='/jsp/About.jsp'/>">About</a></li>
          <li class="nav-item"><a class="nav-link" href="<c:url value='/RoomListServlet'/>">List Room</a></li>
          <li class="nav-item"><a class="nav-link" href="<c:url value='/jsp/ManagerCustomer.jsp'/>">Contact</a></li>
        </ul>
        <div class="nav-social-link">
          <a href="#"><i class="fa fa-facebook"></i></a>
          <a href="#"><i class="fa fa-google-plus"></i></a>
          <a href="#"><i class="fa fa-linkedin"></i></a>
        </div>
      </nav>
    </div>
  </div>
</header>
