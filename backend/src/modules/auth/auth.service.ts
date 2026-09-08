import { Injectable, UnauthorizedException, Logger } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { LoginDto } from './dto/login.dto';

// Mock users (replace with database query in production)
const MOCK_USERS = [
  {
    id: 'usr_qam_001',
    username: 'qam_ledger_admin',
    password: 'password', // In production: bcrypt hash
    name: 'م. أحمد سليمان',
    role: 'branch_accountant',
    branch_code: 'QAM',
    city_ar: 'القامشلي',
  },
  {
    id: 'usr_has_001',
    username: 'has_ledger_admin',
    password: 'password',
    name: 'م. محمد علي',
    role: 'branch_accountant',
    branch_code: 'HAS',
    city_ar: 'الحسكة',
  },
  {
    id: 'usr_der_001',
    username: 'der_ledger_admin',
    password: 'password',
    name: 'م. فاطمة خالد',
    role: 'branch_accountant',
    branch_code: 'DER',
    city_ar: 'الديراعية',
  },
];

@Injectable()
export class AuthService {
  private logger = new Logger(AuthService.name);

  constructor(
    private jwtService: JwtService,
    private configService: ConfigService,
  ) {}

  async login(loginDto: LoginDto) {
    const { username, password } = loginDto;

    // Find user (mock implementation)
    const user = MOCK_USERS.find((u) => u.username === username);

    if (!user || user.password !== password) {
      this.logger.warn(`Failed login attempt for user: ${username}`);
      throw new UnauthorizedException('Invalid credentials');
    }

    // Create JWT payload
    const payload = {
      user_id: user.id,
      username: user.username,
      role: user.role,
      branch_code: user.branch_code,
    };

    const access_token = this.jwtService.sign(payload);

    this.logger.log(`User logged in: ${username} (${user.branch_code})`);

    return {
      success: true,
      timestamp: new Date().toISOString(),
      data: {
        access_token,
        user: {
          id: user.id,
          name: user.name,
          role: user.role,
          branch: user.branch_code,
          city_ar: user.city_ar,
        },
        ui_theme: this.getBranchTheme(user.branch_code),
      },
    };
  }

  private getBranchTheme(branchCode: string) {
    const themes = {
      QAM: {
        primary_accent: '#00E5FF',
        glow_class: 'glow-cyan',
        glow_color: 'rgba(0, 229, 255, 0.15)',
        sidebar_logo_url: '/assets/Logo QAM.jpg',
      },
      HAS: {
        primary_accent: '#FF6B6B',
        glow_class: 'glow-red',
        glow_color: 'rgba(255, 107, 107, 0.15)',
        sidebar_logo_url: '/assets/Logo HAS.jpg',
      },
      DER: {
        primary_accent: '#4ECDC4',
        glow_class: 'glow-teal',
        glow_color: 'rgba(78, 205, 196, 0.15)',
        sidebar_logo_url: '/assets/Logo DER.jpg',
      },
    };

    return themes[branchCode] || themes.QAM;
  }
}
