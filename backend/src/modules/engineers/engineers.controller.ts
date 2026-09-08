import { Controller, Get, Query, UseGuards, Logger } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { EngineersService } from './engineers.service';

@Controller('api/v1/engineers')
@UseGuards(AuthGuard('jwt'))
export class EngineersController {
  private logger = new Logger(EngineersController.name);

  constructor(private engineersService: EngineersService) {}

  @Get()
  async listEngineers(
    @Query('discipline_code') disciplineCode?: string,
    @Query('branch_code') branchCode?: string,
  ) {
    this.logger.debug(
      `Fetching engineers: discipline=${disciplineCode}, branch=${branchCode}`,
    );
    return this.engineersService.findAll({ disciplineCode, branchCode });
  }
}
