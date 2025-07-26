<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="keywords" content="" />
    <meta name="author" content="" />
    <meta name="robots" content="" />
    <meta name="description" content="${blog.title} - Luxury Hotel Blog" />
    <meta property="og:title" content="${blog.title} - Luxury Hotel" />
    <meta property="og:description" content="${blog.title}" />
    <meta property="og:image" content="${pageContext.request.contextPath}/uploads/${blog.imageUrl}" />
    <meta name="format-detection" content="telephone=no">
    <link rel="icon" href="${pageContext.request.contextPath}/assets/images/favicon.ico" type="image/x-icon" />
    <link rel="shortcut icon" type="image/x-icon" href="${pageContext.request.contextPath}/assets/images/favicon.png" />
    <title>${blog.title} - Luxury Hotel Blog</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/assets.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/typography.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/shortcodes/shortcodes.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    <link class="skin" rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/color/color-1.css">
    
    <style>
        .blog-detail-image {
            width: 100%;
            max-height: 500px;
            object-fit: cover;
            border-radius: 5px;
        }
        .comment-item {
            border-bottom: 1px solid #eee;
            padding: 20px 0;
        }
        .comment-item:last-child {
            border-bottom: none;
        }
        .comment-author {
            font-weight: 600;
            color: #333;
        }
        .comment-date {
            font-size: 12px;
            color: #999;
        }
        .comment-content {
            margin-top: 10px;
        }
        .comment-status {
            display: inline-block;
            padding: 3px 10px;
            border-radius: 15px;
            font-size: 11px;
            margin-left: 10px;
        }
        .status-pending {
            background: #fff3cd;
            color: #856404;
        }
        .status-approved {
            background: #d4edda;
            color: #155724;
        }
        .widget-post img {
            width: 80px;
            height: 60px;
            object-fit: cover;
        }
        .search-results {
            max-height: 400px;
            overflow-y: auto;
        }
        .search-results .list-group-item {
            padding: 10px;
        }
        .search-results .list-group-item h6 {
            font-size: 14px;
            margin-bottom: 5px;
        }
        .search-results .list-group-item.active {
            background-color: #007bff;
            border-color: #007bff;
        }
        .logged-in-info {
            background: #e7f3ff;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 15px;
            font-size: 14px;
        }
        .logged-in-info i {
            color: #007bff;
        }
        .widget-post.current-blog {
            background-color: #e7f3ff;
            padding: 10px;
            border-radius: 5px;
            margin-bottom: 10px;
        }
        .widget-post.current-blog .post-title a {
            color: #007bff;
            font-weight: 600;
              }
        .post-content {

            white-space: pre-wrap;
            word-break: break-word;
        }
         .page-banner {
                position: relative;
            }
            .search-bar-on-banner {
                position: absolute;
                left: 50%;
                bottom: -30px;        /* đẩy xuống mép dưới banner */
                transform: translateX(-50%);
                width: 100%;
                max-width: 1100px;
                padding-bottom: 10px;
            }
             .comment-list {
            max-height: 400px;
            overflow-y: auto;
        }
    </style>
</head>
    
<body id="bg">
    <div class="page-wraper">
        <header class="header rs-nav">
            <%@ include file="header.jsp" %>
        </header>

        <!-- Blog Details Page -->
        <div class="page-content bg-white">
            <!-- Page Heading -->
            <div class="page-banner ovbl-dark" style="background-image:url(${pageContext.request.contextPath}/assets/images/banner/banner2.jpg);">
                <div class="container">
                    <div class="page-banner-entry">
                        <h1 class="text-white">Blog Detail</h1>
                    </div>
                     <div class="search-bar-on-banner mt-4">
                            <%@ include file="searchRoom.jsp" %>
                        </div>
                </div>
            </div>
            <div class="breadcrumb-row">
                <div class="container">
                    <ul class="list-inline">
                        <li><a href="${pageContext.request.contextPath}/index.jsp">Home</a></li>
                        <li><a href="${pageContext.request.contextPath}/BlogListServlet">Blog</a></li>
                        <li>${blog.title}</li>
                    </ul>
                </div>
            </div>
            
            <div class="content-block">
                <div class="section-area section-sp1">
                    <div class="container">
                        <div class="row">
                            <!-- Blog Content -->
                            <div class="col-lg-8 col-xl-8">
                                <div class="recent-news blog-lg">
                                    <div class="action-box blog-lg">
                                        <c:choose>
                                            <c:when test="${not empty blog.imageUrl}">
                                                <img src="${pageContext.request.contextPath}/assets/images/blog/${blog.imageUrl}"
                                                     alt="${blog.title}" class="blog-detail-image" />
                                            </c:when>
                                            <c:otherwise>
                                                <img src="${pageContext.request.contextPath}/assets/images/blog/default-blog.jpg"
                                                     alt="${blog.title}" class="blog-detail-image" />
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                    <div class="info-bx">
                                        <ul class="media-post">
                                            <li>
                                                <a href="#"><i class="fa fa-calendar"></i>
                                                    <fmt:formatDate value="${blog.createdAt}" pattern="MMMM dd, yyyy"/>
                                                </a>
                                            </li>
                                            <li>
                                                <a href="#"><i class="fa fa-user"></i> ${blog.authorName}</a>
                                            </li>
                                            <li>
                                                <a href="#comments"><i class="fa fa-comments-o"></i>
                                                    ${blog.commentCount} Comment${blog.commentCount != 1 ? 's' : ''}
                                                </a>
                                            </li>
                                        </ul>
                                        <h2 class="post-title">${blog.title}</h2>
                                        <div class="post-content">
                                            ${blog.content}
                                        </div>
                                        
                                        <div class="ttr-divider bg-gray"><i class="icon-dot c-square"></i></div>
                                        
                                        <!-- Share buttons -->
                                        <h6>SHARE THIS POST</h6>
                                        <ul class="list-inline">
                                            <li class="list-inline-item">
                                                <a href="https://www.facebook.com/sharer/sharer.php?u=${pageContext.request.scheme}://${pageContext.request.serverName}${pageContext.request.contextPath}/BlogDetailServlet?id=${blog.id}" 
                                                   target="_blank" class="btn-link">
                                                    <i class="fab fa-facebook-f"></i>
                                                </a>
                                            </li>
                                            <li class="list-inline-item">
                                                <a href="https://twitter.com/intent/tweet?text=${blog.title}&url=${pageContext.request.scheme}://${pageContext.request.serverName}${pageContext.request.contextPath}/BlogDetailServlet?id=${blog.id}" 
                                                   target="_blank" class="btn-link">
                                                    <i class="fab fa-twitter"></i>
                                                </a>
                                            </li>
                                            <li class="list-inline-item">
                                                <a href="https://www.linkedin.com/shareArticle?mini=true&url=${pageContext.request.scheme}://${pageContext.request.serverName}${pageContext.request.contextPath}/BlogDetailServlet?id=${blog.id}&title=${blog.title}" 
                                                   target="_blank" class="btn-link">
                                                    <i class="fab fa-linkedin-in"></i>
                                                </a>
                                            </li>
                                        </ul>
                                        
                                        <div class="ttr-divider bg-gray"><i class="icon-dot c-square"></i></div>
                                    </div>
                                </div>

                                <!-- Comments Section -->
                                <div id="comments" class="comments-area">
                                    <h4 class="comments-title">Comments (${approvedComments.size()})</h4>
                                    
                                    <c:choose>
                                        <c:when test="${not empty approvedComments}">
                                            <div class="comment-list">
                                                <c:forEach var="comment" items="${approvedComments}">
                                                    <div class="comment-item">
                                                        <div class="comment-author">${comment.authorName}</div>
                                                        <div class="comment-date">
                                                            <fmt:formatDate value="${comment.createdAt}" pattern="MMMM dd, yyyy 'at' HH:mm"/>
                                                        </div>
                                                        <div class="comment-content">
                                                            ${comment.content}
                                                        </div>
                                                    </div>
                                                </c:forEach>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <p class="text-muted">No comments yet. Be the first to comment!</p>
                                        </c:otherwise>
                                    </c:choose>
                                </div>

                                <!-- Comment Form -->
                                <div class="comment-respond" id="respond">
                                    <h4 class="comment-reply-title">Leave a Comment</h4>
                                    
                                    <!-- Success/Error Messages -->
                                    <c:if test="${param.success eq '1'}">
                                        <div class="alert alert-success">
                                            <i class="fa fa-check-circle"></i> Your comment has been posted successfully!
                                        </div>
                                    </c:if>
                                    <c:if test="${param.success eq '2'}">
                                        <div class="alert alert-info">
                                            <i class="fa fa-info-circle"></i> Your comment has been submitted and is awaiting moderation.
                                        </div>
                                    </c:if>
                                    <c:if test="${param.error eq '1'}">
                                        <div class="alert alert-danger">
                                            <i class="fa fa-exclamation-circle"></i> Please fill in all required fields.
                                        </div>
                                    </c:if>
                                    <c:if test="${param.error eq 'email'}">
                                        <div class="alert alert-danger">
                                            <i class="fa fa-exclamation-circle"></i> Please enter a valid email address.
                                        </div>
                                    </c:if>
                                    <c:if test="${param.error eq 'emailLen'}">
                                        <div class="alert alert-danger">
                                            <i class="fa fa-exclamation-circle"></i> Email must not exceed 50 characters.
                                        </div>
                                    </c:if>
                                    <c:if test="${param.error eq 'name'}">
                                        <div class="alert alert-danger">
                                            <i class="fa fa-exclamation-circle"></i> Full name must not exceed 50 characters.
                                        </div>
                                    </c:if>
                                    
                                    <!-- Show logged in user info -->
                                    <c:if test="${not empty sessionScope.user}">
                                        <div class="logged-in-info">
                                            <i class="fa fa-user-check"></i> Commenting as <strong>${sessionScope.user.fullName}</strong>
                                        </div>
                                    </c:if>
                                    
                                    <form class="comment-form" method="post" action="${pageContext.request.contextPath}/CommentServlet">
                                        <input type="hidden" name="blogId" value="${blog.id}" />
                                        <input type="hidden" name="action" value="add" />
                                        
                                        <!-- Only show name and email fields if user is NOT logged in -->
                                        <c:if test="${empty sessionScope.user}">
                                            <div class="row">
                                                <div class="col-md-6">
                                                    <div class="form-group">
                                                        <label for="authorName">Name <span class="required">*</span></label>
                                                        <input type="text" name="authorName" id="authorName"
                                                               class="form-control" placeholder="Your Name" maxlength="50" required />
                                                    </div>
                                                </div>
                                                <div class="col-md-6">
                                                    <div class="form-group">
                                                        <label for="email">Email <span class="required">*</span></label>
                                                        <input type="email" name="email" id="email"
                                                               class="form-control" placeholder="Your Email" maxlength="50" required />
                                                    </div>
                                                </div>
                                            </div>
                                        </c:if>
                                        
                                        <div class="form-group">
                                            <label for="content">Comment <span class="required">*</span></label>
                                            <textarea name="content" id="content" rows="6" 
                                                      class="form-control" placeholder="Your Comment" required></textarea>
                                        </div>
                                        
                                        <div class="form-group">
                                            <button type="submit" class="btn btn-primary">Submit Comment</button>
                                            <c:if test="${empty sessionScope.user}">
                                                <a href="${pageContext.request.contextPath}/jsp/login.jsp" class="btn btn-link">
                                                    <i class="fa fa-sign-in-alt"></i> Login to post instantly
                                                </a>
                                            </c:if>
                                        </div>
                                    </form>
                                </div>
                            </div>

                            <!-- Sidebar -->
                            <div class="col-lg-4 col-xl-4">
                                <aside class="side-bar sticky-top">
                                    <!-- Search Widget -->
                                    <div class="widget">
                                        <h6 class="widget-title">Search</h6>
                                        <div class="search-bx style-1">
                                            <form method="get" action="${pageContext.request.contextPath}/BlogDetailServlet" id="searchForm">
                                                <input type="hidden" name="id" value="${blog.id}" />
                                                <input type="hidden" name="searchMode" value="true" />
                                                <div class="input-group">
                                                    <input name="q" type="text" class="form-control" 
                                                           placeholder="Search blogs..." 
                                                           value="${param.q}" />
                                                    <span class="input-group-btn">
                                                        <button type="submit" class="btn btn-primary">
                                                            <i class="fa fa-search"></i>
                                                        </button>
                                                    </span>
                                                </div>
                                            </form>
                                        </div>
                                        
                                        <!-- Search Results -->
                                        <c:if test="${not empty param.q && param.searchMode == 'true'}">
                                            <div class="search-results mt-3">
                                                <h6>Search Results for "${param.q}"</h6>
                                                <c:choose>
                                                    <c:when test="${not empty searchResults}">
                                                        <div class="list-group">
                                                            <c:forEach var="result" items="${searchResults}">
                                                                <a href="${pageContext.request.contextPath}/BlogDetailServlet?id=${result.id}" 
                                                                   class="list-group-item list-group-item-action ${result.id == blog.id ? 'active' : ''}">
                                                                    <div class="d-flex w-100 justify-content-between">
                                                                        <h6 class="mb-1">${result.title}</h6>
                                                                    </div>
                                                                    <small>
                                                                        <fmt:formatDate value="${result.createdAt}" pattern="MMM dd, yyyy"/>
                                                                    </small>
                                                                </a>
                                                            </c:forEach>
                                                        </div>
                                                        <a href="${pageContext.request.contextPath}/BlogSearchServlet?q=${param.q}" 
                                                           class="btn btn-sm btn-primary mt-2">
                                                            View All Results
                                                        </a>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <p class="text-muted">No results found</p>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </c:if>
                                    </div>
                                    
                                    <!-- Recent Posts Widget -->
                                    <div class="widget recent-posts-entry">
                                        <h6 class="widget-title">Recent Posts</h6>
                                        <div class="widget-post-bx">
                                            <c:forEach var="rp" items="${recentPosts}">
                                                <div class="widget-post clearfix ${rp.id == blog.id ? 'current-blog' : ''}">
                                                    <div class="ttr-post-info">
                                                        <div class="ttr-post-header">
                                                            <h6 class="post-title">
                                                                <a href="${pageContext.request.contextPath}/BlogDetailServlet?id=${rp.id}">
                                                                    ${rp.title}
                                                                </a>
                                                            </h6>
                                                        </div>
                                                        <ul class="media-post">
                                                            <li>
                                                                <i class="fa fa-calendar"></i>
                                                                <fmt:formatDate value="${rp.createdAt}" pattern="MMM dd, yyyy"/>
                                                            </li>
                                                        </ul>
                                                    </div>
                                                </div>
                                            </c:forEach>
                                        </div>
                                    </div>
                                    
                                    <!-- Back to Blog Button -->
                                    <div class="widget">
                                        <a href="${pageContext.request.contextPath}/BlogListServlet" 
                                           class="btn btn-primary btn-block">
                                            <i class="fa fa-arrow-left"></i> Back to Blog
                                        </a>
                                    </div>
                                </aside>
                            </div>
                        </div>
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
    
    <script>
        // Validate form before submit
        document.querySelector('.comment-form').addEventListener('submit', function(e) {
            const content = document.getElementById('content').value.trim();
            
            if (content.length < 10) {
                e.preventDefault();
                alert('Please enter a comment with at least 10 characters.');
                return false;
            }
            
            <c:if test="${empty sessionScope.user}">
            // Validate email for non-logged in users
            const email = document.getElementById('email').value;
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(email)) {
                e.preventDefault();
                alert('Please enter a valid email address.');
                return false;
            }
            </c:if>
        });
    </script>
</body>
</html>