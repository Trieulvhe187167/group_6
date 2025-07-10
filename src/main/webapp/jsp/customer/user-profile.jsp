<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Profile</title>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.bundle.min.js"></script>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
        }

        .dashboard-container {
            display: flex;
            min-height: 100vh;
        }

        /* Sidebar Styles */
        .sidebar {
            width: 280px;
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            box-shadow: 4px 0 20px rgba(0, 0, 0, 0.1);
            padding: 0;
            position: fixed;
            height: 100vh;
            z-index: 1000;
            transition: transform 0.3s ease;
        }

        .sidebar-header {
            padding: 30px 25px;
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            text-align: center;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }

        .sidebar-header h3 {
            font-size: 1.4rem;
            font-weight: 600;
            margin-bottom: 5px;
        }

        .sidebar-header p {
            font-size: 0.9rem;
            opacity: 0.8;
        }

        .sidebar-menu {
            list-style: none;
            padding: 20px 0;
        }

        .sidebar-menu li {
            margin: 0;
        }

        .sidebar-menu a {
            display: flex;
            align-items: center;
            padding: 15px 25px;
            color: #495057;
            text-decoration: none;
            transition: all 0.3s ease;
            border-left: 3px solid transparent;
        }

        .sidebar-menu a:hover {
            background: linear-gradient(90deg, rgba(102, 126, 234, 0.1), transparent);
            border-left-color: #667eea;
            color: #667eea;
        }

        .sidebar-menu a.active {
            background: linear-gradient(90deg, rgba(102, 126, 234, 0.15), transparent);
            border-left-color: #667eea;
            color: #667eea;
            font-weight: 600;
        }

        .sidebar-menu i {
            width: 20px;
            margin-right: 15px;
            font-size: 1.1rem;
        }

        .menu-divider {
            height: 1px;
            background: linear-gradient(90deg, transparent, #e9ecef, transparent);
            margin: 15px 0;
        }

        /* Mobile Toggle */
        .mobile-toggle {
            display: none;
            position: fixed;
            top: 20px;
            left: 20px;
            z-index: 1001;
            background: #667eea;
            color: white;
            border: none;
            border-radius: 50%;
            width: 50px;
            height: 50px;
            font-size: 1.2rem;
            cursor: pointer;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
            transition: all 0.3s ease;
        }

        .mobile-toggle:hover {
            background: #764ba2;
            transform: scale(1.05);
        }

        /* Main Content */
        .main-content {
            flex: 1;
            margin-left: 280px;
            padding: 40px;
            transition: margin-left 0.3s ease;
        }

        .content-header {
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(10px);
            border-radius: 15px;
            padding: 30px;
            margin-bottom: 30px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
        }

        .content-header h2 {
            color: #343a40;
            font-size: 2rem;
            font-weight: 700;
            margin-bottom: 10px;
        }

        .content-header p {
            color: #6c757d;
            font-size: 1.1rem;
        }

        /* Profile Card */
        .profile-card {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
            padding: 30px;
            margin-bottom: 25px;
            border: 1px solid rgba(255, 255, 255, 0.2);
        }

        .profile-header {
            display: flex;
            align-items: center;
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 2px solid #f8f9fa;
        }

        .profile-avatar {
            width: 80px;
            height: 80px;
            border-radius: 50%;
            background: linear-gradient(135deg, #667eea, #764ba2);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-size: 2rem;
            margin-right: 20px;
            box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
        }

        .profile-info h3 {
            font-size: 1.5rem;
            font-weight: 600;
            color: #495057;
            margin-bottom: 5px;
        }

        .profile-info p {
            color: #6c757d;
            margin-bottom: 0;
        }

        .form-section {
            margin-bottom: 30px;
        }

        .section-title {
            font-size: 1.2rem;
            font-weight: 600;
            color: #495057;
            margin-bottom: 15px;
            display: flex;
            align-items: center;
        }

        .section-title i {
            margin-right: 10px;
            color: #667eea;
        }

        .form-group {
            margin-bottom: 20px;
        }

        .form-group label {
            font-weight: 600;
            color: #495057;
            margin-bottom: 8px;
            display: block;
        }

        .form-control {
            border: 2px solid #e9ecef;
            border-radius: 10px;
            padding: 12px 15px;
            font-size: 1rem;
            transition: all 0.3s ease;
            background: rgba(255, 255, 255, 0.9);
        }

        .form-control:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 0.2rem rgba(102, 126, 234, 0.25);
            background: white;
        }

        .btn {
            padding: 12px 25px;
            border: none;
            border-radius: 25px;
            font-size: 0.9rem;
            font-weight: 600;
            text-decoration: none;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            cursor: pointer;
            transition: all 0.3s ease;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }

        .btn-primary {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(102, 126, 234, 0.3);
        }

        .btn-secondary {
            background: linear-gradient(135deg, #6c757d, #5a6268);
            color: white;
        }

        .btn-secondary:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(108, 117, 125, 0.3);
        }

        .btn-success {
            background: linear-gradient(135deg, #28a745, #20c997);
            color: white;
        }

        .btn-success:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 20px rgba(40, 167, 69, 0.3);
        }

        /* Alert Messages */
        .alert {
            padding: 15px 20px;
            margin-bottom: 20px;
            border-radius: 10px;
            border: none;
            font-weight: 500;
            display: none;
        }

        .alert-success {
            background: linear-gradient(135deg, #d4edda, #c3e6cb);
            color: #155724;
            border-left: 4px solid #28a745;
        }

        .alert-error {
            background: linear-gradient(135deg, #f8d7da, #f5c6cb);
            color: #721c24;
            border-left: 4px solid #dc3545;
        }

        .alert-info {
            background: linear-gradient(135deg, #d1ecf1, #bee5eb);
            color: #0c5460;
            border-left: 4px solid #17a2b8;
        }

        /* Email Verification Section */
        .email-verification {
            background: linear-gradient(135deg, rgba(23, 162, 184, 0.1), rgba(23, 162, 184, 0.05));
            padding: 20px;
            border-radius: 15px;
            border-left: 4px solid #17a2b8;
            margin-bottom: 20px;
        }

        .verification-status {
            display: flex;
            align-items: center;
            margin-bottom: 15px;
        }

        .verification-status i {
            margin-right: 10px;
            font-size: 1.2rem;
        }

        .status-verified {
            color: #28a745;
        }

        .status-pending {
            color: #ffc107;
        }

        .status-unverified {
            color: #dc3545;
        }

        /* Modal Styles */
        .modal-content {
            border-radius: 20px;
            border: none;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
        }

        .modal-header {
            background: linear-gradient(135deg, #667eea, #764ba2);
            color: white;
            border-radius: 20px 20px 0 0;
            padding: 20px 30px;
            border-bottom: none;
        }

        .modal-header h5 {
            margin: 0;
            font-weight: 600;
        }

        .modal-body {
            padding: 30px;
        }

        .code-input {
            display: flex;
            gap: 10px;
            justify-content: center;
            margin: 20px 0;
        }

        .code-input input {
            width: 45px;
            height: 45px;
            text-align: center;
            font-size: 1.2rem;
            font-weight: 600;
            border: 2px solid #e9ecef;
            border-radius: 10px;
            background: rgba(255, 255, 255, 0.9);
            transition: all 0.3s ease;
        }

        .code-input input:focus {
            border-color: #667eea;
            box-shadow: 0 0 0 0.2rem rgba(102, 126, 234, 0.25);
            background: white;
        }

        .timer {
            text-align: center;
            margin: 15px 0;
            font-size: 1.1rem;
            color: #6c757d;
        }

        .timer.expired {
            color: #dc3545;
        }

        /* Responsive Design */
        @media (max-width: 768px) {
            .mobile-toggle {
                display: block;
            }

            .sidebar {
                transform: translateX(-100%);
            }

            .sidebar.active {
                transform: translateX(0);
            }

            .main-content {
                margin-left: 0;
                padding: 80px 20px 40px;
            }

            .profile-header {
                flex-direction: column;
                text-align: center;
            }

            .profile-avatar {
                margin-right: 0;
                margin-bottom: 15px;
            }

            .content-header {
                padding: 25px 20px;
            }

            .content-header h2 {
                font-size: 1.6rem;
            }

            .profile-card {
                padding: 25px 20px;
            }

            .code-input {
                flex-wrap: wrap;
                gap: 8px;
            }

            .code-input input {
                width: 40px;
                height: 40px;
            }
        }

        /* Sidebar overlay for mobile */
        .sidebar-overlay {
            display: none;
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
            z-index: 999;
        }

        .sidebar-overlay.active {
            display: block;
        }
    </style>
</head>
<body>
    <!-- Mobile Toggle Button -->
    <button class="mobile-toggle" onclick="toggleSidebar()">
        <i class="fas fa-bars"></i>
    </button>

    <!-- Sidebar Overlay -->
    <div class="sidebar-overlay" onclick="toggleSidebar()"></div>

    <div class="dashboard-container">
        <!-- Sidebar -->
        <nav class="sidebar" id="sidebar">
            <div class="sidebar-header">
                <h3><i class="fas fa-user-circle"></i> Customer Panel</h3>
                <p>Welcome back!</p>
            </div>
            <ul class="sidebar-menu">
                <li>
                    <a href="my-booking.jsp">
                        <i class="fas fa-calendar-check"></i>
                        <span>My Bookings</span>
                    </a>
                </li>
                <li>
                    <a href="booking-history.jsp">
                        <i class="fas fa-history"></i>
                        <span>Booking History</span>
                    </a>
                </li>
                <div class="menu-divider"></div>
                <li>
                    <a href="#" class="active">
                        <i class="fas fa-user-edit"></i>
                        <span>User Profile</span>
                    </a>
                </li>
                <li>
                    <a href="change-password.jsp">
                        <i class="fas fa-key"></i>
                        <span>Change Password</span>
                    </a>
                </li>
                <div class="menu-divider"></div>
                <li>
                    <a href="index.jsp">
                        <i class="fas fa-home"></i>
                        <span>Homepage</span>
                    </a>
                </li>
                <li>
                    <a href="search-rooms.jsp">
                        <i class="fas fa-search"></i>
                        <span>Search Rooms</span>
                    </a>
                </li>
                <li>
                    <a href="support.jsp">
                        <i class="fas fa-headset"></i>
                        <span>Support</span>
                    </a>
                </li>
                <div class="menu-divider"></div>
                <li>
                    <a href="logout.jsp" style="color: #dc3545;">
                        <i class="fas fa-sign-out-alt"></i>
                        <span>Logout</span>
                    </a>
                </li>
            </ul>
        </nav>

        <!-- Main Content -->
        <main class="main-content">
            <div class="content-header">
                <h2><i class="fas fa-user-edit"></i> User Profile</h2>
                <p>Manage your account settings and personal information</p>
            </div>

            <!-- Alert Messages -->
            <div class="alert alert-success" id="successAlert">
                <i class="fas fa-check-circle"></i> <span id="successMessage"></span>
            </div>

            <div class="alert alert-error" id="errorAlert">
                <i class="fas fa-exclamation-triangle"></i> <span id="errorMessage"></span>
            </div>

            <div class="alert alert-info" id="infoAlert">
                <i class="fas fa-info-circle"></i> <span id="infoMessage"></span>
            </div>

            <!-- Profile Card -->
            <div class="profile-card">
                <div class="profile-header">
                    <div class="profile-avatar">
                        <i class="fas fa-user"></i>
                    </div>
                    <div class="profile-info">
                        <h3>John Doe</h3>
                        <p>Customer Account</p>
                    </div>
                </div>

                <!-- Personal Information Section -->
                <div class="form-section">
                    <h4 class="section-title">
                        <i class="fas fa-user"></i>
                        Personal Information
                    </h4>
                    
                    <form id="profileForm">
                        <div class="row">
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label for="firstName">First Name</label>
                                    <input type="text" class="form-control" id="firstName" value="John" required>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="form-group">
                                    <label for="lastName">Last Name</label>
                                    <input type="text" class="form-control" id="lastName" value="Doe" required>
                                </div>
                            </div>
                        </div>
                        
                        <div class="form-group">
                            <label for="phone">Phone Number</label>
                            <input type="tel" class="form-control" id="phone" value="+1 234 567 8900" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="address">Address</label>
                            <textarea class="form-control" id="address" rows="3" placeholder="Enter your address">123 Main Street, City, State 12345</textarea>
                        </div>
                        
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-save"></i>
                            Update Profile
                        </button>
                    </form>
                </div>

                <!-- Email Section -->
                <div class="form-section">
                    <h4 class="section-title">
                        <i class="fas fa-envelope"></i>
                        Email Settings
                    </h4>
                    
                    <div class="email-verification">
                        <div class="verification-status">
                            <i class="fas fa-check-circle status-verified"></i>
                            <span><strong>Email Verified:</strong> john.doe@email.com</span>
                        </div>
                        <p>Your email address is verified and secure.</p>
                    </div>
                    
                    <form id="emailForm">
                        <div class="form-group">
                            <label for="newEmail">New Email Address</label>
                            <input type="email" class="form-control" id="newEmail" placeholder="Enter new email address">
                        </div>
                        
                        <button type="submit" class="btn btn-secondary">
                            <i class="fas fa-envelope"></i>
                            Update Email
                        </button>
                    </form>
                </div>

                <!-- Password Section -->
                <div class="form-section">
                    <h4 class="section-title">
                        <i class="fas fa-lock"></i>
                        Password Settings
                    </h4>
                    
                    <form id="passwordForm">
                        <div class="form-group">
                            <label for="currentPassword">Current Password</label>
                            <input type="password" class="form-control" id="currentPassword" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="newPassword">New Password</label>
                            <input type="password" class="form-control" id="newPassword" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="confirmPassword">Confirm New Password</label>
                            <input type="password" class="form-control" id="confirmPassword" required>
                        </div>
                        
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-key"></i>
                            Change Password
                        </button>
                    </form>
                </div>
            </div>
        </main>
    </div>

    <!-- Email Verification Modal -->
    <div class="modal fade" id="emailVerificationModal" tabindex="-1" role="dialog" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">
                        <i class="fas fa-envelope"></i>
                        Email Verification
                    </h5>
                    <button type="button" class="close" data-dismiss="modal">
                        <span>&times;</span>
                    </button>
                </div>
                <div class="modal-body">
                    <div class="text-center">
                        <i class="fas fa-envelope-open-text" style="font-size: 3rem; color: #667eea; margin-bottom: 20px;"></i>
                        <h5>Verification Code Sent</h5>
                        <p>We've sent a 6-digit verification code to your new email address. Please enter the code below to verify your email.</p>
                        
                        <div class="code-input">
                            <input type="text" maxlength="1" class="code-digit" data-index="0">
                            <input type="text" maxlength="1" class="code-digit" data-index="1">
                            <input type="text" maxlength="1" class="code-digit" data-index="2">
                            <input type="text" maxlength="1" class="code-digit" data-index="3">
                            <input type="text" maxlength="1" class="code-digit" data-index="4">
                            <input type="text" maxlength="1" class="code-digit" data-index="5">
                        </div>
                        
                        <div class="timer" id="verificationTimer">
                            Time remaining: <span id="timerDisplay">05:00</span>
                        </div>
                        
                        <button type="button" class="btn btn-success" id="verifyCodeBtn">
                            <i class="fas fa-check"></i>
                            Verify Code
                        </button>
                        
                        <button type="button" class="btn btn-secondary" id="resendCodeBtn" disabled>
                            <i class="fas fa-redo"></i>
                            Resend Code
                        </button>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        // Global variables
        let verificationTimer;
        let timeLeft = 300; // 5 minutes in seconds
        let currentEmail = '';

        // Initialize page
        document.addEventListener('DOMContentLoaded', function() {
            setupCodeInputs();
            setupFormHandlers();
        });

        // Toggle sidebar
        function toggleSidebar() {
            const sidebar = document.getElementById('sidebar');
            const overlay = document.querySelector('.sidebar-overlay');
            
            sidebar.classList.toggle('active');
            overlay.classList.toggle('active');
        }

        // Setup code input behavior
        function setupCodeInputs() {
            const codeInputs = document.querySelectorAll('.code-digit');
            
            codeInputs.forEach((input, index) => {
                input.addEventListener('input', function(e) {
                    const value = e.target.value.replace(/[^0-9]/g, '');
                    e.target.value = value;
                    
                    if (value && index < codeInputs.length - 1) {
                        codeInputs[index + 1].focus();
                    }
                });
                
                input.addEventListener('keydown', function(e) {
                    if (e.key === 'Backspace' && !e.target.value && index > 0) {
                        codeInputs[index - 1].focus();
                    }
                });
                
                input.addEventListener('paste', function(e) {
                    e.preventDefault();
                    const paste = e.clipboardData.getData('text').replace(/[^0-9]/g, '');
                    
                    for (let i = 0; i < Math.min(paste.length, codeInputs.length - index); i++) {
                        codeInputs[index + i].value = paste[i];
                    }
                });
            });
        }

        // Setup form handlers
        function setupFormHandlers() {
            // Profile form handler
            document.getElementById('profileForm').addEventListener('submit', function(e) {
                e.preventDefault();
                showAlert('success', 'Profile updated successfully!');
            });

            // Email form handler
            document.getElementById('emailForm').addEventListener('submit', function(e) {
                e.preventDefault();
                const newEmail = document.getElementById('newEmail').value;
                
                if (!newEmail) {
                    showAlert('error', 'Please enter a new email address.');
                    return;
                }
                
                if (!isValidEmail(newEmail)) {
                    showAlert('error', 'Please enter a valid email address.');
                    return;
                }
                
                currentEmail = newEmail;
                startEmailVerification();
            });

            // Password form handler
            document.getElementById('passwordForm').addEventListener('submit', function(e) {
                e.preventDefault();
                const currentPassword = document.getElementById('currentPassword').value;
                const newPassword = document.getElementById('newPassword').value;
                const confirmPassword = document.getElementById('confirmPassword').value;
                
                if (!currentPassword || !newPassword || !confirmPassword) {
                    showAlert('error', 'Please fill in all password fields.');
                    return;
                }
                
                if (newPassword !== confirmPassword) {
                    showAlert('error', 'New passwords do not match.');
                    return;
                }
                
                if (newPassword.length < 8) {
                    showAlert('error', 'Password must be at least 8 characters long.');
                    return;
                }
                
                // Simulate password change
                showAlert('success', 'Password changed successfully!');
                document.getElementById('passwordForm').reset();
            });

            // Verification code handler
            document.getElementById('verifyCodeBtn').addEventListener('click', verifyCode);
            document.getElementById('resendCodeBtn').addEventListener('click', resendCode);
        }

        // Start email verification process
        function startEmailVerification() {
            $('#emailVerificationModal').modal('show');
            startTimer();
            showAlert('info', `Verification code sent to ${currentEmail}`);
        }

        // Start countdown timer
        function startTimer() {
            timeLeft = 300; // Reset to 5 minutes
            document.getElementById('resendCodeBtn').disabled = true;
            
            verificationTimer = setInterval(function() {
                timeLeft--;
                updateTimerDisplay();
                
                if (timeLeft <= 0) {
                    clearInterval(verificationTimer);
                    document.getElementById('resendCodeBtn').disabled = false;
                    document.getElementById('verificationTimer').className = 'timer expired';
                    document.getElementById('timerDisplay').textContent = 'Expired';
                }
            }, 1000);
        }

        // Update timer display
        function updateTimerDisplay() {
            const minutes = Math.floor(timeLeft / 60);
            const seconds = timeLeft % 60;
            document.getElementById('timerDisplay').textContent = 
                `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
        }

        // Verify code
        function verifyCode() {
            const codeInputs = document.querySelectorAll('.code-digit');
            const code = Array.from(codeInputs).map(input => input.value).join('');
            
            if (code.length !== 6) {
                showAlert('error', 'Please enter all 6 digits.');
                return;
            }
            
            // Simulate verification (in real app, send to server)
            const isValid = code === '123456'; // Demo code
            
            if (isValid) {
                clearInterval(verificationTimer);
                $('#emailVerificationModal').modal('hide');
                showAlert('success', 'Email verified successfully!');
                document.getElementById('newEmail').value = '';
                
                // Update email verification status
                const verificationStatus = document.querySelector('.verification-status');
                verificationStatus.innerHTML = `
                    <i class="fas fa-check-circle status-verified"></i>
                    <span><strong>Email Verified:</strong> ${currentEmail}</span>
                `;
            } else {
                showAlert('error', 'Invalid verification code. Please try again.');
            }
        }

        // Resend verification code
        function resendCode() {
            clearInterval(verificationTimer);
            
            // Clear current code inputs
            document.querySelectorAll('.code-digit').forEach(input => {
                input.value = '';
            });
            
            // Reset timer
            document.getElementById('verificationTimer').className = 'timer';
            startTimer();
            
            showAlert('info', 'New verification code sent to your email.');
        }

        // Show alert messages
        function showAlert(type, message) {
            // Hide all alerts first
            document.querySelectorAll('.alert').forEach(alert => {
                alert.style.display = 'none';
            });
            
            // Show specific alert
            const alertId = type === 'success' ? 'successAlert' : 
                           type === 'error' ? 'errorAlert' : 'infoAlert';
            const messageId = type === 'success' ? 'successMessage' : 
                             type === 'error' ? 'errorMessage' : 'infoMessage';
            
            document.getElementById(messageId).textContent = message;
            document.getElementById(alertId).style.display = 'block';
            
            // Auto-hide after 5 seconds
            setTimeout(function() {
                document.getElementById(alertId).style.display = 'none';
            }, 5000);
            
            // Scroll to top to show alert
            window.scrollTo({top: 0, behavior: 'smooth'});
        }

        // Email validation
        function isValidEmail(email) {
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            return emailRegex.test(email);
        }

        // Close sidebar when clicking on overlay
        document.querySelector('.sidebar-overlay').addEventListener('click', function() {
            toggleSidebar();
        });

        // Handle modal close
        $('#emailVerificationModal').on('hidden.bs.modal', function () {
            clearInterval(verificationTimer);
            document.querySelectorAll('.code-digit').forEach(input => {
                input.value = '';
            });
            document.getElementById('verificationTimer').className = 'timer';
            document.getElementById('resendCodeBtn').disabled = false;
        });

        // Auto-focus first code input when modal opens
        $('#emailVerificationModal').on('shown.bs.modal', function () {
            document.querySelector('.code-digit').focus();
        });

        // Handle Enter key in forms
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Enter') {
                const activeElement = document.activeElement;
                
                // If in verification modal
                if (document.getElementById('emailVerificationModal').classList.contains('show')) {
                    if (activeElement.classList.contains('code-digit')) {
                        verifyCode();
                    }
                }
            }
        });

        // Generate random verification code (for demo)
        function generateVerificationCode() {
            return Math.floor(100000 + Math.random() * 900000).toString();
        }

        // Simulate sending email (in real app, this would be a server call)
        function sendVerificationEmail(email) {
            const code = generateVerificationCode();
            console.log(`Verification code for ${email}: ${code}`);
            
            // In real application, you would send this to your server
            // which would then send the email
            return new Promise((resolve) => {
                setTimeout(() => {
                    resolve({ success: true, code: code });
                }, 1000);
            });
        }

        // Password strength checker
        function checkPasswordStrength(password) {
            let strength = 0;
            const checks = {
                length: password.length >= 8,
                uppercase: /[A-Z]/.test(password),
                lowercase: /[a-z]/.test(password),
                number: /\d/.test(password),
                special: /[!@#$%^&*(),.?":{}|<>]/.test(password)
            };
            
            Object.values(checks).forEach(check => {
                if (check) strength++;
            });
            
            return {
                score: strength,
                checks: checks,
                level: strength < 3 ? 'weak' : strength < 4 ? 'medium' : 'strong'
            };
        }

        // Add password strength indicator
        document.getElementById('newPassword').addEventListener('input', function() {
            const password = this.value;
            const strength = checkPasswordStrength(password);
            
            // You can add a password strength indicator here
            console.log('Password strength:', strength.level);
        });

        // Form validation enhancement
        function validateForm(formId) {
            const form = document.getElementById(formId);
            const inputs = form.querySelectorAll('input[required]');
            let isValid = true;
            
            inputs.forEach(input => {
                if (!input.value.trim()) {
                    input.classList.add('is-invalid');
                    isValid = false;
                } else {
                    input.classList.remove('is-invalid');
                }
            });
            
            return isValid;
        }

        // Add loading states to buttons
        function setButtonLoading(button, isLoading) {
            if (isLoading) {
                button.disabled = true;
                const originalText = button.innerHTML;
                button.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Processing...';
                button.dataset.originalText = originalText;
            } else {
                button.disabled = false;
                button.innerHTML = button.dataset.originalText;
            }
        }

        // Enhanced form submission with loading states
        function enhanceFormSubmission() {
            const forms = document.querySelectorAll('form');
            
            forms.forEach(form => {
                form.addEventListener('submit', function(e) {
                    const submitBtn = form.querySelector('button[type="submit"]');
                    if (submitBtn) {
                        setButtonLoading(submitBtn, true);
                        
                        // Simulate processing delay
                        setTimeout(() => {
                            setButtonLoading(submitBtn, false);
                        }, 2000);
                    }
                });
            });
        }

        // Initialize enhanced features
        document.addEventListener('DOMContentLoaded', function() {
            enhanceFormSubmission();
        });
    </script>
</body>
</html>