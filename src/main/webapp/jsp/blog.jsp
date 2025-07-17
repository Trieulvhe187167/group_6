<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<!DOCTYPE html>
<html lang="en">
    <head>
        <!-- META -->
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="keywords" content="" />
        <meta name="author" content="" />
        <meta name="robots" content="" />
        <meta name="description" content="Blog - Luxury Hotel" />
        <meta property="og:title" content="Blog - Luxury Hotel" />
        <meta property="og:description" content="Blog - Luxury Hotel" />
        <meta property="og:image" content="" />
        <meta name="format-detection" content="telephone=no">
        <link rel="icon" href="${pageContext.request.contextPath}/assets/images/favicon.ico" type="image/x-icon" />
        <link rel="shortcut icon" type="image/x-icon" href="${pageContext.request.contextPath}/assets/images/favicon.png" />
        <title>Blog - Luxury Hotel</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <!-- CSS -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/assets.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/typography.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/shortcodes/shortcodes.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
        <link class="skin" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/color/color-1.css">
        
        <style>
            .blog-image {
                width: 100%;
                height: 250px;
                object-fit: cover;
                border-radius: 5px;
            }
            .search-box {
                margin-bottom: 30px;
            }
            .blog-card {
                height: 100%;
                transition: transform 0.3s;
            }
            .blog-card:hover {
                transform: translateY(-5px);
            }
            .post-content-preview {
                max-height: 100px;
                overflow: hidden;
                text-overflow: ellipsis;
                display: -webkit-box;
                -webkit-line-clamp: 3;
                -webkit-box-orient: vertical;
            }
           .pagination-bx .pagination {
    margin: 15px;
}
        </style>
    </head>
    <body id="bg">
        <div class="page-wraper">
            <div id="loading-icon-bx"></div>
            <!-- Header -->
            <header class="header rs-nav">
                <%@ include file="header.jsp" %>
            </header>

            <!-- Inner Content Box -->
            <div class="page-content bg-white">
                <!-- Page Heading -->
                <div class="page-banner ovbl-dark" style="background-image:url(${pageContext.request.contextPath}/assets/images/banner/banner2.jpg);">
                    <div class="container">
                        <div class="page-banner-entry">
                            <h1 class="text-white">Our Blog</h1>
                        </div>
                    </div>
                </div>
                <div class="breadcrumb-row">
                    <div class="container">
                        <ul class="list-inline">
                            <li><a href="${pageContext.request.contextPath}/index.jsp">Home</a></li>
                            <li>Blog</li>
                        </ul>
                    </div>
                </div>

                <!-- Blog Content -->
                <div class="content-block">
                    <div class="section-area section-sp1">
                        <div class="container">
                            <!-- Search Box -->
                            <div class="row search-box">
                                <div class="col-md-6 mx-auto">
                                    <form action="${pageContext.request.contextPath}/BlogSearchServlet" method="get">
                                        <div class="input-group">
                                            <input type="text" name="q" class="form-control" 
                                                   placeholder="Search blogs..." 
                                                   value="${param.q}">
                                            <div class="input-group-append">
                                                <button class="btn btn-primary" type="submit">
                                                    <i class="fa fa-search"></i> Search
                                                </button>
                                            </div>
                                        </div>
                                    </form>
                                </div>
                            </div>
                            
                            <!-- Search Results Message -->
                            <c:if test="${not empty param.q}">
                                <div class="alert alert-info">
                                    <c:choose>
                                        <c:when test="${not empty blogs}">
                                            Found ${blogs.size()} result(s) for "<strong>${param.q}</strong>"
                                        </c:when>
                                        <c:otherwise>
                                            No results found for "<strong>${param.q}</strong>"
                                        </c:otherwise>
                                    </c:choose>
                                    <a href="${pageContext.request.contextPath}/BlogListServlet" class="float-right">Clear search</a>
                                </div>
                            </c:if>
                            
                            <!-- Blog Grid -->
                            <div class="row">
                                <c:forEach var="blog" items="${blogs}">                      
                                    <div class="col-md-4 col-sm-6 m-b30">         
                                        <div class="blog-card recent-news">
                                            <c:choose>
                                                <c:when test="${not empty blog.imageUrl}">
                                                    <img src="${pageContext.request.contextPath}/assets/images/blog/${blog.imageUrl}"
                                                         alt="${blog.title}"
                                                         class="blog-image" />
                                                </c:when>
                                                <c:otherwise>
                                                    <img src="${pageContext.request.contextPath}/assets/images/blog/default-blog.jpg"
                                                         alt="${blog.title}"
                                                         class="blog-image" />
                                                </c:otherwise>
                                            </c:choose>

                                            <div class="info-bx p-3">
                                                <ul class="media-post">
                                                    <li>
                                                        <a href="#"><i class="fa fa-calendar"></i>
                                                            <fmt:formatDate value="${blog.createdAt}" pattern="MMM dd, yyyy"/>
                                                        </a>
                                                    </li>
                                                    <li>
                                                        <a href="#"><i class="fa fa-user"></i>
                                                            ${blog.authorName}
                                                        </a>
                                                    </li>
                                                </ul>
                                                <h5 class="post-title">
                                                    <a href="${pageContext.request.contextPath}/BlogDetailServlet?id=${blog.id}">
                                                        ${blog.title}
                                                    </a>
                                                </h5>
                                                <div class="post-content-preview">
                                                    ${fn:substring(fn:replace(blog.content, '<[^>]*>', ''), 0, 150)}...
                                                </div>
                                                <div class="d-flex justify-content-between align-items-center mt-3">
                                                    <a href="${pageContext.request.contextPath}/BlogDetailServlet?id=${blog.id}"
                                                       class="btn-link">
                                                        READ MORE <i class="fa fa-arrow-right"></i>
                                                    </a>
                                                    <a href="#" class="comments-bx">
                                                        <i class="fa fa-comments-o"></i> ${blog.commentCount}
                                                    </a>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>

                            <!-- No blogs message -->
                            <c:if test="${empty blogs}">
                                <div class="text-center py-5">
                                    <i class="fa fa-newspaper-o fa-3x text-muted mb-3"></i>
                                    <h4>No blogs available</h4>
                                    <p class="text-muted">Check back later for new content!</p>
                                </div>
                            </c:if>

                            <!-- Pagination -->
                            <c:if test="${totalPages > 1}">
                                <div class="pagination-bx rounded-sm gray clearfix">
                                     <ul class="pagination justify-content-center">
                                        <c:if test="${currentPage > 1}">
                                            <li class="previous">
                                                <a href="?page=${currentPage - 1}<c:if test="${not empty param.q}">&q=${param.q}</c:if>">
                                                    <i class="ti-arrow-left"></i> Prev
                                                </a>
                                            </li>
                                        </c:if>
                                        
                                        <c:forEach begin="1" end="${totalPages}" var="i">
                                            <li class="${i == currentPage ? 'active' : ''}">
                                                <a href="?page=${i}<c:if test="${not empty param.q}">&q=${param.q}</c:if>">${i}</a>
                                            </li>
                                        </c:forEach>
                                        
                                        <c:if test="${currentPage < totalPages}">
                                            <li class="next">
                                                <a href="?page=${currentPage + 1}<c:if test="${not empty param.q}">&q=${param.q}</c:if>">
                                                    Next <i class="ti-arrow-right"></i>
                                                </a>
                                            </li>
                                        </c:if>
                                    </ul>
                                </div>
                            </c:if>
                        </div>
                    </div>
                </div>
            </div>
            
            <%@ include file="footer.jsp" %>
        </div>

        <!-- JS -->
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
    </body>
</html>