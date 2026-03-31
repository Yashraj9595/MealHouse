import nodemailer from 'nodemailer';
import { config } from '../config/config';
import { IEmailOptions, IOTPEmailData } from '../types';

class EmailService {
  private transporter: nodemailer.Transporter;

  constructor() {
    this.transporter = nodemailer.createTransport({
      host: config.EMAIL_HOST,
      port: config.EMAIL_PORT,
      secure: config.EMAIL_SECURE,
      auth: {
        user: config.EMAIL_USER,
        pass: config.EMAIL_PASS
      }
    });
  }

  /**
   * Send email
   */
  async sendEmail(options: IEmailOptions): Promise<void> {
    try {
      const mailOptions = {
        from: config.EMAIL_FROM,
        to: options.to,
        subject: options.subject,
        html: options.html,
        text: options.text
      };

      await this.transporter.sendMail(mailOptions);
      console.log(`Email sent successfully to ${options.to}`);
    } catch (error) {
      console.error('Email sending failed:', error);
      throw new Error('Failed to send email');
    }
  }

  /**
   * Send OTP email
   */
  async sendOTPEmail(email: string, otpData: IOTPEmailData): Promise<void> {
    const subject = this.getOTPEmailSubject(otpData.type);
    const html = this.generateOTPEmailHTML(otpData);
    const text = this.generateOTPEmailText(otpData);

    await this.sendEmail({
      to: email,
      subject,
      html,
      text
    });
  }

  /**
   * Send welcome email
   */
  async sendWelcomeEmail(email: string, firstName: string): Promise<void> {
    const subject = 'Welcome to Auth App!';
    const html = this.generateWelcomeEmailHTML(firstName);
    const text = this.generateWelcomeEmailText(firstName);

    await this.sendEmail({
      to: email,
      subject,
      html,
      text
    });
  }

  /**
   * Send password reset email
   */
  async sendPasswordResetEmail(email: string, resetLink: string): Promise<void> {
    const subject = 'Password Reset Request';
    const html = this.generatePasswordResetEmailHTML(resetLink);
    const text = this.generatePasswordResetEmailText(resetLink);

    await this.sendEmail({
      to: email,
      subject,
      html,
      text
    });
  }

  /**
   * Get OTP email subject based on type
   */
  private getOTPEmailSubject(type: string): string {
    switch (type) {
      case 'email_verification':
        return 'Verify Your Email Address';
      case 'password_reset':
        return 'Password Reset OTP';
      case 'mobile_verification':
        return 'Mobile Verification OTP';
      case 'login':
        return 'Login OTP';
      default:
        return 'Your OTP Code';
    }
  }

  /**
   * Generate OTP email HTML
   */
  private generateOTPEmailHTML(otpData: IOTPEmailData): string {
    return `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>OTP Verification</title>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: #4f46e5; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }
          .content { background: #f9fafb; padding: 30px; border-radius: 0 0 8px 8px; }
          .otp-code { background: #1f2937; color: white; font-size: 32px; font-weight: bold; text-align: center; padding: 20px; border-radius: 8px; letter-spacing: 4px; margin: 20px 0; }
          .footer { text-align: center; margin-top: 30px; color: #6b7280; font-size: 14px; }
          .warning { background: #fef3c7; border: 1px solid #f59e0b; padding: 15px; border-radius: 8px; margin: 20px 0; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>OTP Verification</h1>
          </div>
          <div class="content">
            <h2>Your Verification Code</h2>
            <p>Please use the following code to complete your ${otpData.type.replace('_', ' ')}:</p>
            
            <div class="otp-code">${otpData.otp}</div>
            
            <div class="warning">
              <strong>Important:</strong> This code will expire in ${otpData.expiresIn}. Do not share this code with anyone.
            </div>
            
            <p>If you didn't request this code, please ignore this email.</p>
          </div>
          <div class="footer">
            <p>This is an automated message. Please do not reply to this email.</p>
            <p>&copy; 2024 Auth App. All rights reserved.</p>
          </div>
        </div>
      </body>
      </html>
    `;
  }

  /**
   * Generate OTP email text
   */
  private generateOTPEmailText(otpData: IOTPEmailData): string {
    return `
OTP Verification

Your verification code is: ${otpData.otp}

This code will expire in ${otpData.expiresIn}.

If you didn't request this code, please ignore this email.

---
Auth App
    `;
  }

  /**
   * Generate welcome email HTML
   */
  private generateWelcomeEmailHTML(firstName: string): string {
    return `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Welcome to Auth App</title>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: #10b981; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }
          .content { background: #f9fafb; padding: 30px; border-radius: 0 0 8px 8px; }
          .footer { text-align: center; margin-top: 30px; color: #6b7280; font-size: 14px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>Welcome to Auth App!</h1>
          </div>
          <div class="content">
            <h2>Hello ${firstName}!</h2>
            <p>Welcome to Auth App! Your account has been successfully created.</p>
            <p>You can now access all the features of our platform with your new account.</p>
            <p>If you have any questions, feel free to contact our support team.</p>
          </div>
          <div class="footer">
            <p>&copy; 2024 Auth App. All rights reserved.</p>
          </div>
        </div>
      </body>
      </html>
    `;
  }

  /**
   * Generate welcome email text
   */
  private generateWelcomeEmailText(firstName: string): string {
    return `
Welcome to Auth App!

Hello ${firstName}!

Welcome to Auth App! Your account has been successfully created.

You can now access all the features of our platform with your new account.

If you have any questions, feel free to contact our support team.

---
Auth App
    `;
  }

  /**
   * Generate password reset email HTML
   */
  private generatePasswordResetEmailHTML(resetLink: string): string {
    return `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Password Reset</title>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background: #dc2626; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }
          .content { background: #f9fafb; padding: 30px; border-radius: 0 0 8px 8px; }
          .button { background: #4f46e5; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; display: inline-block; margin: 20px 0; }
          .footer { text-align: center; margin-top: 30px; color: #6b7280; font-size: 14px; }
          .warning { background: #fef3c7; border: 1px solid #f59e0b; padding: 15px; border-radius: 8px; margin: 20px 0; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>Password Reset Request</h1>
          </div>
          <div class="content">
            <h2>Reset Your Password</h2>
            <p>You requested to reset your password. Click the button below to reset it:</p>
            
            <a href="${resetLink}" class="button">Reset Password</a>
            
            <div class="warning">
              <strong>Important:</strong> This link will expire in 1 hour. If you didn't request this reset, please ignore this email.
            </div>
            
            <p>If the button doesn't work, copy and paste this link into your browser:</p>
            <p style="word-break: break-all; color: #4f46e5;">${resetLink}</p>
          </div>
          <div class="footer">
            <p>This is an automated message. Please do not reply to this email.</p>
            <p>&copy; 2024 Auth App. All rights reserved.</p>
          </div>
        </div>
      </body>
      </html>
    `;
  }

  /**
   * Generate password reset email text
   */
  private generatePasswordResetEmailText(resetLink: string): string {
    return `
Password Reset Request

You requested to reset your password. Click the link below to reset it:

${resetLink}

This link will expire in 1 hour. If you didn't request this reset, please ignore this email.

---
Auth App
    `;
  }
}

export const emailService = new EmailService();
